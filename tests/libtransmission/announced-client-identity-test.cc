// This file Copyright © Transmission authors and contributors.
// It may be used under GPLv2 (SPDX: GPL-2.0-only), GPLv3 (SPDX: GPL-3.0-only),
// or any future license endorsed by Mnemosyne LLC.
// License text can be found in the licenses/ folder.

#include <algorithm>
#include <array>
#include <atomic>
#include <set>
#include <string>
#include <string_view>

#include <gtest/gtest.h>

#include <libtransmission/transmission.h>

#include <libtransmission/announced-client-identity.h>
#include <libtransmission/clients.h>
#include <libtransmission/session.h> // TR_NAME
#include <libtransmission/torrent.h>
#include <libtransmission/version.h>

#include "test-fixtures.h"

using namespace std::literals;

namespace
{
[[nodiscard]] std::string_view peer_id_prefix(tr_peer_id_t const& peer_id)
{
    return { std::data(peer_id), 8U };
}

[[nodiscard]] std::string client_for_prefix(std::string_view const prefix)
{
    auto peer_id = tr_peer_id_t{};
    std::copy(std::begin(prefix), std::end(prefix), std::begin(peer_id));

    auto buf = std::array<char, 128>{};
    tr_clientForId(std::data(buf), std::size(buf), peer_id);
    return std::data(buf);
}
} // namespace

TEST(AnnouncedClientIdentity, tableEntriesAreWellFormed)
{
    auto ids = std::set<std::string_view>{};
    for (auto const& identity : tr_announced_client_identities())
    {
        EXPECT_FALSE(std::empty(identity.id));
        EXPECT_FALSE(std::empty(identity.display_name));
        EXPECT_FALSE(std::empty(identity.version));
        EXPECT_EQ(8U, std::size(identity.peer_id_prefix)) << identity.id;
        EXPECT_FALSE(std::empty(identity.http_user_agent));
        EXPECT_FALSE(std::empty(identity.ltep_client));
        EXPECT_TRUE(ids.insert(identity.id).second) << identity.id;
    }
}

TEST(AnnouncedClientIdentity, realIdentityMatchesBuildMacros)
{
    auto const& real = tr_announced_client_identity_real();

    EXPECT_EQ("real"sv, real.id);
    EXPECT_EQ(std::string_view{ TR_NAME " " USERAGENT_PREFIX }, real.display_name);
    EXPECT_EQ(std::string_view{ USERAGENT_PREFIX }, real.version);
    EXPECT_EQ(std::string_view{ PEERID_PREFIX }, real.peer_id_prefix);
    EXPECT_EQ(std::string_view{ TR_NAME "/" SHORT_VERSION_STRING }, real.http_user_agent);
    EXPECT_EQ(std::string_view{ TR_NAME " " USERAGENT_PREFIX }, real.ltep_client);
}

TEST(AnnouncedClientIdentity, historicalIdentitiesMatchExpectedProtocolStrings)
{
    struct ExpectedIdentity
    {
        std::string_view id;
        std::string_view display_name;
        std::string_view version;
        std::string_view peer_id_prefix;
        std::string_view http_user_agent;
        std::string_view ltep_client;
        std::string_view decoded_client;
    };

    auto constexpr Expected = std::array<ExpectedIdentity, 8>{ {
        { "transmission-4.1.2"sv, "Transmission 4.1.2"sv, "4.1.2"sv, "-TR4120-"sv, "Transmission/4.1.2"sv,
          "Transmission 4.1.2"sv, "Transmission 4.1.2"sv },
        { "transmission-4.1.1"sv, "Transmission 4.1.1"sv, "4.1.1"sv, "-TR4110-"sv, "Transmission/4.1.1"sv,
          "Transmission 4.1.1"sv, "Transmission 4.1.1"sv },
        { "transmission-4.1.0"sv, "Transmission 4.1.0"sv, "4.1.0"sv, "-TR4100-"sv, "Transmission/4.1.0"sv,
          "Transmission 4.1.0"sv, "Transmission 4.1.0"sv },
        { "transmission-4.0.6"sv, "Transmission 4.0.6"sv, "4.0.6"sv, "-TR4060-"sv, "Transmission/4.0.6"sv,
          "Transmission 4.0.6"sv, "Transmission 4.0.6"sv },
        { "transmission-4.0.5"sv, "Transmission 4.0.5"sv, "4.0.5"sv, "-TR4050-"sv, "Transmission/4.0.5"sv,
          "Transmission 4.0.5"sv, "Transmission 4.0.5"sv },
        { "transmission-3.00"sv, "Transmission 3.00"sv, "3.00"sv, "-TR3000-"sv, "Transmission/3.00"sv,
          "Transmission 3.00"sv, "Transmission 3.00"sv },
        { "transmission-2.94"sv, "Transmission 2.94"sv, "2.94"sv, "-TR2940-"sv, "Transmission/2.94"sv,
          "Transmission 2.94"sv, "Transmission 2.94"sv },
        { "transmission-2.84"sv, "Transmission 2.84"sv, "2.84"sv, "-TR2840-"sv, "Transmission/2.84"sv,
          "Transmission 2.84"sv, "Transmission 2.84"sv },
    } };

    for (auto const& expected : Expected)
    {
        auto const* identity = tr_announced_client_identity_find(expected.id);
        ASSERT_NE(nullptr, identity) << expected.id;

        EXPECT_EQ(expected.display_name, identity->display_name);
        EXPECT_EQ(expected.version, identity->version);
        EXPECT_EQ(expected.peer_id_prefix, identity->peer_id_prefix);
        EXPECT_EQ(expected.http_user_agent, identity->http_user_agent);
        EXPECT_EQ(expected.ltep_client, identity->ltep_client);
        EXPECT_EQ(expected.decoded_client, client_for_prefix(identity->peer_id_prefix));
    }
}

TEST(AnnouncedClientIdentity, lookupNormalizesRealIdentity)
{
    EXPECT_EQ(&tr_announced_client_identity_real(), tr_announced_client_identity_find({}));
    EXPECT_EQ(&tr_announced_client_identity_real(), tr_announced_client_identity_find("real"sv));
    EXPECT_EQ(nullptr, tr_announced_client_identity_find("4.0.5"sv));
    EXPECT_EQ(nullptr, tr_announced_client_identity_find("transmission-9.99"sv));
}

TEST(AnnouncedClientIdentity, publicListApiMirrorsTable)
{
    auto const identities = tr_announced_client_identities();
    ASSERT_EQ(std::size(identities), tr_announcedClientIdentityCount());

    for (size_t i = 0; i < std::size(identities); ++i)
    {
        auto const public_identity = tr_announcedClientIdentity(i);
        ASSERT_NE(nullptr, public_identity.id);
        ASSERT_NE(nullptr, public_identity.display_name);
        EXPECT_EQ(identities[i].id, std::string_view{ public_identity.id });
        EXPECT_EQ(identities[i].display_name, std::string_view{ public_identity.display_name });
    }

    auto const out_of_range = tr_announcedClientIdentity(std::size(identities));
    EXPECT_EQ(nullptr, out_of_range.id);
    EXPECT_EQ(nullptr, out_of_range.display_name);
}

using AnnouncedClientIdentityTorrentTest = tr::test::SessionTest;

TEST_F(AnnouncedClientIdentityTorrentTest, torrentSetResetAndInvalidIdentity)
{
    auto* const tor = zeroTorrentMagnetInit();

    EXPECT_STREQ("real", tr_torrentGetAnnouncedClientIdentity(tor));
    EXPECT_EQ(std::string_view{ PEERID_PREFIX }, peer_id_prefix(tor->peer_id()));
    EXPECT_EQ(std::string_view{ TR_NAME "/" SHORT_VERSION_STRING }, tor->announce_user_agent());
    EXPECT_EQ(std::string_view{ TR_NAME " " USERAGENT_PREFIX }, tor->extended_protocol_client_version());

    ASSERT_TRUE(tr_torrentSetAnnouncedClientIdentity(tor, "transmission-2.94"));
    EXPECT_STREQ("transmission-2.94", tr_torrentGetAnnouncedClientIdentity(tor));
    EXPECT_EQ("-TR2940-"sv, peer_id_prefix(tor->peer_id()));
    EXPECT_EQ("Transmission/2.94"sv, tor->announce_user_agent());
    EXPECT_EQ("Transmission 2.94"sv, tor->extended_protocol_client_version());

    EXPECT_FALSE(tr_torrentSetAnnouncedClientIdentity(tor, "Transmission/4.0.5"));
    EXPECT_STREQ("transmission-2.94", tr_torrentGetAnnouncedClientIdentity(tor));
    EXPECT_EQ("-TR2940-"sv, peer_id_prefix(tor->peer_id()));
    EXPECT_EQ("Transmission/2.94"sv, tor->announce_user_agent());
    EXPECT_EQ("Transmission 2.94"sv, tor->extended_protocol_client_version());

    ASSERT_TRUE(tr_torrentSetAnnouncedClientIdentity(tor, ""));
    EXPECT_STREQ("real", tr_torrentGetAnnouncedClientIdentity(tor));
    EXPECT_EQ(std::string_view{ PEERID_PREFIX }, peer_id_prefix(tor->peer_id()));
    EXPECT_EQ(std::string_view{ TR_NAME "/" SHORT_VERSION_STRING }, tor->announce_user_agent());
    EXPECT_EQ(std::string_view{ TR_NAME " " USERAGENT_PREFIX }, tor->extended_protocol_client_version());

    ASSERT_TRUE(tr_torrentSetAnnouncedClientIdentity(tor, nullptr));
    EXPECT_STREQ("real", tr_torrentGetAnnouncedClientIdentity(tor));
}

TEST_F(AnnouncedClientIdentityTorrentTest, runningTorrentDefersActiveIdentityUntilStopped)
{
    auto* const tor = zeroTorrentMagnetInit();

    auto started = std::atomic_bool{ false };
    tor->started_.connect([&started](tr_torrent*) { started = true; });

    tr_torrentStartNow(tor);
    ASSERT_TRUE(tr::test::waitFor([&started] { return started.load(); }, 5s));
    ASSERT_TRUE(tor->is_running());

    ASSERT_TRUE(tr_torrentSetAnnouncedClientIdentity(tor, "transmission-4.0.5"));
    EXPECT_STREQ("transmission-4.0.5", tr_torrentGetAnnouncedClientIdentity(tor));
    EXPECT_EQ(std::string_view{ PEERID_PREFIX }, peer_id_prefix(tor->peer_id()));
    EXPECT_EQ(std::string_view{ TR_NAME "/" SHORT_VERSION_STRING }, tor->announce_user_agent());
    EXPECT_EQ(std::string_view{ TR_NAME " " USERAGENT_PREFIX }, tor->extended_protocol_client_version());

    tr_torrentStop(tor);
    ASSERT_TRUE(tr::test::waitFor([tor] { return peer_id_prefix(tor->peer_id()) == "-TR4050-"sv; }, 5s));
    EXPECT_FALSE(tor->is_running());
    EXPECT_EQ("Transmission/4.0.5"sv, tor->announce_user_agent());
    EXPECT_EQ("Transmission 4.0.5"sv, tor->extended_protocol_client_version());
}
