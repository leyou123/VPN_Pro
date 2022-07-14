//
//  SVPPacketTunnelProvider.h
//  PacketTunnel
//
//  Created by MacOSDaye on 2021/9/22.
//

@import NetworkExtension;

NS_ASSUME_NONNULL_BEGIN

@interface PacketTunnelProvider : NEPacketTunnelProvider

typedef NS_ENUM(NSInteger, ErrorCode) {
    svp_noError = 0,
    svp_undefinedError = 1,
    svp_vpnPermissionNotGranted = 2,
    svp_invalidServerCredentials = 3,
    svp_udpRelayNotEnabled = 4,
    svp_serverUnreachable = 5,
    svp_vpnStartFailure = 6,
    svp_illegalServerConfiguration = 7,
    svp_shadowsocksStartFailure = 8,
    svp_configureSystemProxyFailure = 9,
    svp_noAdminPermissions = 10,
    svp_unsupportedRoutingTable = 11,
    svp_systemMisconfigured = 12
};

@end

NS_ASSUME_NONNULL_END
