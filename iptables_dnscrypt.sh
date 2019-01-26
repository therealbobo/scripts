#! /bin/bash

iptables -t nat -F
ip6tables -t nat -F


#fallback
#iptables -t nat -A PREROUTING -p udp --dport 5301 -j REDIRECT --to-port 53
#iptables -t nat -A OUTPUT -p udp --dport 5301 -j REDIRECT --to-port 53
#
iptables -t nat -A OUTPUT -p udp --dport 5301 -j DNAT --to 1.1.1.1:53
iptables -t nat -A OUTPUT -p udp --dport 5302 -j DNAT --to 137.204.25.71:53

iptables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to 127.0.0.1:5300
iptables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to 127.0.0.1:5300
ip6tables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to [::1]:5300
ip6tables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to [::1]:5300


