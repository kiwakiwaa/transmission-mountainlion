// This file Copyright © Transmission authors and contributors.
// It may be used under GPLv2 (SPDX: GPL-2.0-only), GPLv3 (SPDX: GPL-3.0-only),
// or any future license endorsed by Mnemosyne LLC.
// License text can be found in the licenses/ folder.

#include <array>
#include <cstddef> // size_t
#include <span>
#include <string_view>

#include "libtransmission/transmission.h"

#include "libtransmission/announced-client-identity.h"
#include "libtransmission/session.h" // TR_NAME
#include "libtransmission/version.h"

using namespace std::literals;

namespace
{
auto constexpr RealIdentityId = "real"sv;

auto constexpr Identities = std::array<tr_announced_client_identity, 9>{ {
    {
        .id = RealIdentityId,
        .display_name = TR_NAME " " USERAGENT_PREFIX,
        .version = USERAGENT_PREFIX,
        .peer_id_prefix = PEERID_PREFIX,
        .http_user_agent = TR_NAME "/" SHORT_VERSION_STRING,
        .ltep_client = TR_NAME " " USERAGENT_PREFIX,
    },
    {
        .id = "transmission-4.1.2"sv,
        .display_name = "Transmission 4.1.2"sv,
        .version = "4.1.2"sv,
        .peer_id_prefix = "-TR4120-"sv,
        .http_user_agent = "Transmission/4.1.2"sv,
        .ltep_client = "Transmission 4.1.2"sv,
    },
    {
        .id = "transmission-4.1.1"sv,
        .display_name = "Transmission 4.1.1"sv,
        .version = "4.1.1"sv,
        .peer_id_prefix = "-TR4110-"sv,
        .http_user_agent = "Transmission/4.1.1"sv,
        .ltep_client = "Transmission 4.1.1"sv,
    },
    {
        .id = "transmission-4.1.0"sv,
        .display_name = "Transmission 4.1.0"sv,
        .version = "4.1.0"sv,
        .peer_id_prefix = "-TR4100-"sv,
        .http_user_agent = "Transmission/4.1.0"sv,
        .ltep_client = "Transmission 4.1.0"sv,
    },
    {
        .id = "transmission-4.0.6"sv,
        .display_name = "Transmission 4.0.6"sv,
        .version = "4.0.6"sv,
        .peer_id_prefix = "-TR4060-"sv,
        .http_user_agent = "Transmission/4.0.6"sv,
        .ltep_client = "Transmission 4.0.6"sv,
    },
    {
        .id = "transmission-4.0.5"sv,
        .display_name = "Transmission 4.0.5"sv,
        .version = "4.0.5"sv,
        .peer_id_prefix = "-TR4050-"sv,
        .http_user_agent = "Transmission/4.0.5"sv,
        .ltep_client = "Transmission 4.0.5"sv,
    },
    {
        .id = "transmission-3.00"sv,
        .display_name = "Transmission 3.00"sv,
        .version = "3.00"sv,
        .peer_id_prefix = "-TR3000-"sv,
        .http_user_agent = "Transmission/3.00"sv,
        .ltep_client = "Transmission 3.00"sv,
    },
    {
        .id = "transmission-2.94"sv,
        .display_name = "Transmission 2.94"sv,
        .version = "2.94"sv,
        .peer_id_prefix = "-TR2940-"sv,
        .http_user_agent = "Transmission/2.94"sv,
        .ltep_client = "Transmission 2.94"sv,
    },
    {
        .id = "transmission-2.84"sv,
        .display_name = "Transmission 2.84"sv,
        .version = "2.84"sv,
        .peer_id_prefix = "-TR2840-"sv,
        .http_user_agent = "Transmission/2.84"sv,
        .ltep_client = "Transmission 2.84"sv,
    },
} };
} // namespace

std::span<tr_announced_client_identity const> tr_announced_client_identities() noexcept
{
    return Identities;
}

tr_announced_client_identity const& tr_announced_client_identity_real() noexcept
{
    return Identities.front();
}

tr_announced_client_identity const* tr_announced_client_identity_find(std::string_view id) noexcept
{
    if (std::empty(id) || id == RealIdentityId)
    {
        return &tr_announced_client_identity_real();
    }

    for (auto const& identity : tr_announced_client_identities())
    {
        if (identity.id == id)
        {
            return &identity;
        }
    }

    return nullptr;
}

size_t tr_announcedClientIdentityCount()
{
    return std::size(Identities);
}

tr_announced_client_identity_info tr_announcedClientIdentity(size_t const index)
{
    if (index >= std::size(Identities))
    {
        return {};
    }

    auto const& identity = Identities[index];
    return {
        .id = std::data(identity.id),
        .display_name = std::data(identity.display_name),
    };
}

