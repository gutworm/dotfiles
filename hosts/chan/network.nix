{ pkgs, ... }:
{
  networking = {
    hostName = "chan";
    enableIPv6 = true;
    useNetworkd = true;
    wireless.iwd.enable = true;
    resolvconf.useLocalResolver = true;
    firewall.enable = false;
    useDHCP = false;
    nftables = {
      enable = true;
      flushRuleset = true;
      tables = {
        filter = {
          family = "inet";
          content = ''
            chain input {
              type filter hook input priority 0; policy drop;
              iif lo accept comment "accept loopback"
              iif != lo ip daddr 127.0.0.1/8 counter drop comment "drop connections to loopback not coming from loopback"
              iif != lo ip6 daddr ::1/128 counter drop comment "drop connections to loopback not coming from loopback"
              ct state {established, related} counter accept comment "accept all connections related to connections made by us"
              ct state invalid counter drop comment "early drop of invalid packets"

              ip saddr 192.168.31.0/24 tcp dport { 22000, 53317 } accept comment "Syncthing, LocalSend"
              ip saddr 192.168.31.0/24 udp dport { 21027, 22000, 53317 } accept comment "Syncthing, LocalSend"
              tcp dport 50300 accept comment "slskd"
              udp dport 50300 accept comment "slskd"

              # allow "ping"
              ip6 nexthdr icmpv6 icmpv6 type echo-request accept
              ip protocol icmp icmp type echo-request accept

              # ICMP
              ip6 nexthdr icmpv6 icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } accept
              ip protocol icmp icmp type { destination-unreachable, router-advertisement, time-exceeded, parameter-problem } accept

              counter comment "count dropped packets"
            }

	    # Allow all outgoing connections.
            chain output {
              type filter hook output priority 0; policy accept;
            }

            chain forward {
              type filter hook forward priority 0; policy drop;
            }
          '';
        };
      };
    };
  };

  systemd = {
    network = {
      enable = true;
      wait-online.enable = false;
      networks = {
        "10-wireless" = {
          name = "wlan0";
          DHCP = "yes";
          dhcpConfig.UseDNS = false;
        };
        "20-ethernet" = {
          name = "enp0s31f6";
          DHCP = "yes";
          dhcpConfig.UseDNS = false;
          linkConfig.RequiredForOnline = "no";
        };
      };
    };
  };

  boot.initrd.systemd.network.wait-online.enable = false;

  services = {
    openssh = {
      enable = true;
      ports = [ 58530 ];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        UseDns = true;
      };
    };

    dnscrypt-proxy = {
      enable = true;
      upstreamDefaults = true;
      settings = {
        listen_addresses = [
          "127.0.0.1:53"
          "[::1]:53"
        ];
        require_dnssec = true;
        require_nofilter = true;
        require_nolog = true;
        doh_servers = true;
        block_ipv6 = false;

        cache_size = 2048;
        cache_min_ttl = 3600;
        cache_max_ttl = 86400;
        cache_neg_min_ttl = 60;
        cache_neg_max_ttl = 300;

        server_names = [ "NextDNS-c8df27" ];

        static = {
          "NextDNS-c8df27" = {
            stamp = "sdns://AgEAAAAAAAAAAAAOZG5zLm5leHRkbnMuaW8HL2M4ZGYyNw";
          };
        };
        cloaking_rules = pkgs.writeText "cloaking-rules.txt" "";
      };
    };
  };
}
