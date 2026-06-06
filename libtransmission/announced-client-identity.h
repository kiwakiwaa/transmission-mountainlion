// This file Copyright © Transmission authors and contributors.
// It may be used under GPLv2 (SPDX: GPL-2.0-only), GPLv3 (SPDX: GPL-3.0-only),
// or any future license endorsed by Mnemosyne LLC.
// License text can be found in the licenses/ folder.

#pragma once

#ifndef __TRANSMISSION__
#error only libtransmission should #include this header.
#endif

#include <span>
#include <string_view>

struct tr_announced_client_identity
{
    std::string_view id;
    std::string_view display_name;
    std::string_view version;
    std::string_view peer_id_prefix;
    std::string_view http_user_agent;
    std::string_view ltep_client;
};

[[nodiscard]] std::span<tr_announced_client_identity const> tr_announced_client_identities() noexcept;

[[nodiscard]] tr_announced_client_identity const& tr_announced_client_identity_real() noexcept;

[[nodiscard]] tr_announced_client_identity const* tr_announced_client_identity_find(std::string_view id) noexcept;
