//
//  SVPConnector.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/13.
//

#import "SVPConnector.h"
#import <NetworkExtension/NetworkExtension.h>

#ifdef DEBUG
#define Log(format, ...) NSLog((@"[文件名:%s]" "[函数名:%s]" "[行号:%d]" format), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define Log(...);
#endif

@interface SVPConnector()

@property (nonatomic, strong) NEVPNManager *svpServerManager;

@end

@implementation SVPConnector

+ (instancetype)svp_ServerConnector {
    
    SVPConnector *svp_connector = [[SVPConnector alloc] init];
    svp_connector.svpServerManager = [NEVPNManager sharedManager];
    [[NSNotificationCenter defaultCenter] addObserver:svp_connector
                                             selector:@selector(svpConnectorServerStatusDidChanged:)
                                                 name:NEVPNStatusDidChangeNotification
                                               object:nil];
    return svp_connector;
}

- (void)checkSVPServerPreferenceSuccess:(void (^)(BOOL isInstalled))successBlock {
    
    [_svpServerManager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            Log(@"加载 VPN 偏好设置失败 : %@", error);
            if ([self.delegate respondsToSelector:@selector(svpServerConnectionDidRecieveError:)]) {
                [self.delegate svpServerConnectionDidRecieveError:SVPServerConnectorErrorLoadPrefrence];
            }
        } else {
            if ([[NSString stringWithFormat:@"%@", self.svpServerManager.protocolConfiguration] rangeOfString:@"persistentReference"].location != NSNotFound) {
                successBlock ? successBlock(YES) : 0;
            } else {
                // 不存在
                successBlock ? successBlock(NO) : 0;
            }
        }
    }];
}


- (void)createSVPServerPreferenceWithData:(id)data success:(void (^)(void))successBlock {
    SVPSeverInfo *vpnInfo = [SVPSeverInfo setupSVPInfoWithData:data];
    [_svpServerManager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            Log(@"加载 VPN 偏好设置失败 : %@", error);
            if ([self.delegate respondsToSelector:@selector(svpServerConnectionDidRecieveError:)]) {
                [self.delegate svpServerConnectionDidRecieveError:SVPServerConnectorErrorLoadPrefrence];
            }
        } else {
            NSUserDefaults *moreDefaults = [NSUserDefaults standardUserDefaults];
            NSString *selectedString = [moreDefaults objectForKey:@"selected"];
            if ([selectedString integerValue] == 1) {
                NEVPNProtocolIKEv2 *protocol = [[NEVPNProtocolIKEv2 alloc] init];
                protocol.serverAddress = vpnInfo.svp_serverAddress;
                protocol.remoteIdentifier = vpnInfo.svp_remoteID;
                protocol.username = vpnInfo.svp_username;
                
                // 设置密码
                static NSString *passwordKey = @"password";
                [self setKeychainWithString:vpnInfo.svp_password forIdentifier:passwordKey];
                protocol.passwordReference = [self getDataReferenceInKeychainFromIdentifier:passwordKey];
                
#warning Change if need (Choose one)
                // 如果你的 VPN 服务器是使用密码和共享密码进行双向认证，则使用以下代码
                // 共享密码
                static NSString *sharedSecretKey = @"sharedSecret";
                [self setKeychainWithString:vpnInfo.svp_sharedSecret forIdentifier:sharedSecretKey];
                protocol.sharedSecretReference = [self getDataReferenceInKeychainFromIdentifier:sharedSecretKey];
                
                // 其他配置
                protocol.authenticationMethod = NEVPNIKEAuthenticationMethodNone;
                
#warning Change if need (Choose one)
                /*
                 // 如果你的 VPN 服务器是只需要用户名，然后使用 CA 证书进行认证，则使用以下代码
                 // 设置认证方式为使用证书
                 protocol.authenticationMethod = NEVPNIKEAuthenticationMethodCertificate;
                 // 安装证书代码自己在合适的地方编写，一般使用 Safari 进行安装
                 // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"xxxx.ca.cert.pem"]];
                 */
                
                protocol.useExtendedAuthentication = YES;
                protocol.disconnectOnSleep = NO;
                
                self.svpServerManager.protocolConfiguration = protocol;
                self.svpServerManager.onDemandEnabled = YES;
                self.svpServerManager.localizedDescription = vpnInfo.svp_preferenceTitle;
                self.svpServerManager.enabled = YES;
            }
            if ([selectedString integerValue] == 2) {
                NEVPNProtocolIPSec *protocol = [[NEVPNProtocolIPSec alloc] init];
                protocol.serverAddress = vpnInfo.svp_serverAddress;
                protocol.remoteIdentifier = vpnInfo.svp_remoteID;
                protocol.username = vpnInfo.svp_username;
                
                // 设置密码
                static NSString *passwordKey = @"password";
                [self setKeychainWithString:vpnInfo.svp_password forIdentifier:passwordKey];
                protocol.passwordReference = [self getDataReferenceInKeychainFromIdentifier:passwordKey];
                
#warning Change if need (Choose one)
                // 如果你的 VPN 服务器是使用密码和共享密码进行双向认证，则使用以下代码
                // 共享密码
                static NSString *sharedSecretKey = @"sharedSecret";
                [self setKeychainWithString:vpnInfo.svp_sharedSecret forIdentifier:sharedSecretKey];
                protocol.sharedSecretReference = [self getDataReferenceInKeychainFromIdentifier:sharedSecretKey];
                
                // 其他配置
                protocol.authenticationMethod = NEVPNIKEAuthenticationMethodSharedSecret;
                
#warning Change if need (Choose one)
                /*
                 // 如果你的 VPN 服务器是只需要用户名，然后使用 CA 证书进行认证，则使用以下代码
                 // 设置认证方式为使用证书
                 protocol.authenticationMethod = NEVPNIKEAuthenticationMethodCertificate;
                 // 安装证书代码自己在合适的地方编写，一般使用 Safari 进行安装
                 // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"xxxx.ca.cert.pem"]];
                 */
                
                protocol.useExtendedAuthentication = YES;
                protocol.disconnectOnSleep = NO;
                
                self.svpServerManager.protocolConfiguration = protocol;
                self.svpServerManager.onDemandEnabled = YES;
                self.svpServerManager.localizedDescription = vpnInfo.svp_preferenceTitle;
                self.svpServerManager.enabled = YES;
            }
            
            [self.svpServerManager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
                if (error) {
                    Log(@"保存 VPN 偏好设置失败 : %@", error);
                    if ([self.delegate respondsToSelector:@selector(svpServerConnectionDidRecieveError:)]) {
                        [self.delegate svpServerConnectionDidRecieveError:SVPServerConnectorErrorSavePrefrence];
                    }
                } else {
                    [self checkSVPServerPreferenceSuccess:^(BOOL isInstalled) {
                        if (isInstalled) {
                            successBlock ? successBlock() : 0;
                        }
                    }];
                }
            }];
        }
    }];
}

- (void)removeSVPServerPreferenceSuccess:(void (^)(void))successBlock {
    [self.svpServerManager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            Log(@"加载 VPN 偏好设置失败 : %@", error);
            if ([self.delegate respondsToSelector:@selector(svpServerConnectionDidRecieveError:)]) {
                [self.delegate svpServerConnectionDidRecieveError:SVPServerConnectorErrorLoadPrefrence];
            }
        } else {
            [self.svpServerManager removeFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
                if (error) {
                    Log(@"删除 VPN 偏好设置失败 : %@", error);
                    if ([self.delegate respondsToSelector:@selector(svpServerConnectionDidRecieveError:)]) {
                        [self.delegate svpServerConnectionDidRecieveError:SVPServerConnectorErrorRemovePrefrence];
                    }
                } else {
                    self.svpServerManager.protocolConfiguration = nil;
                    successBlock ? successBlock() : 0;
                }
            }];
        }
    }];
}

- (void)modifySVPServerPreferenceWithData:(id)data success:(void (^)(void))successBlock {
    
    [self createSVPServerPreferenceWithData:data success:^{
        successBlock ? successBlock() : 0;
    }];
}

- (void)startSVPServerConnectSuccess:(void (^)(void))successBlock {
    [self.svpServerManager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            Log(@"加载 VPN 偏好设置失败 : %@", error);
            if ([self.delegate respondsToSelector:@selector(svpServerConnectionDidRecieveError:)]) {
                [self.delegate svpServerConnectionDidRecieveError:SVPServerConnectorErrorLoadPrefrence];
            }
        } else {
            NSError *returnError;
            [self.svpServerManager.connection startVPNTunnelAndReturnError:&returnError];
            if (returnError) {
                Log(@"启动 VPN 失败 : %@", returnError);
                if ([self.delegate respondsToSelector:@selector(svpServerConnectionDidRecieveError:)]) {
                    [self.delegate svpServerConnectionDidRecieveError:SVPServerConnectorErrorStartVPNConnect];
                }
            } else {
                successBlock ? successBlock() : 0;
            }
        }
    }];
}


- (void)stopSVPServerConnectSuccess:(void (^)(void))successBlock {
    [self.svpServerManager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            Log(@"加载 VPN 偏好设置失败 : %@", error);
            if ([self.delegate respondsToSelector:@selector(svpServerConnectionDidRecieveError:)]) {
                [self.delegate svpServerConnectionDidRecieveError:SVPServerConnectorErrorLoadPrefrence];
            }
        } else {
            [self.svpServerManager.connection stopVPNTunnel];
            successBlock ? successBlock() : 0;
        }
    }];
}

- (SVPSeverInfo *)getCurrentSVPServerInfo {
    
    SVPSeverInfo *svpServerInfo = [[SVPSeverInfo alloc] init];
    NSUserDefaults *moreDefaults = [NSUserDefaults standardUserDefaults];
    NSString *selectedString = [moreDefaults objectForKey:@"selected"];
    if ([selectedString integerValue] == 1) {
        NEVPNProtocolIKEv2 *svp_protocol = (NEVPNProtocolIKEv2 *)_svpServerManager.protocolConfiguration;
        svpServerInfo.svp_serverAddress = svp_protocol.serverAddress;
        svpServerInfo.svp_remoteID = svp_protocol.remoteIdentifier;
        svpServerInfo.svp_username = svp_protocol.username;
    }
    if ([selectedString integerValue] == 2) {
        NEVPNProtocolIPSec *svp_protocol = (NEVPNProtocolIPSec *)_svpServerManager.protocolConfiguration;
        svpServerInfo.svp_serverAddress = svp_protocol.serverAddress;
        svpServerInfo.svp_remoteID = svp_protocol.remoteIdentifier;
        svpServerInfo.svp_username = svp_protocol.username;
    }
    return svpServerInfo;
}

- (SVPServerStatus)getCurrentSVPServerStatus {
    
    NEVPNStatus status = _svpServerManager.connection.status;
    switch (status) {
        case NEVPNStatusInvalid:
            return SVPServerStatusInvalid;
            break;
        case NEVPNStatusDisconnected:
            return SVPServerStatusDisconnected;
            break;
        case NEVPNStatusConnecting:
            return SVPServerStatusConnecting;
            break;
        case NEVPNStatusConnected:
            return SVPServerStatusConnecting;
            break;
        case NEVPNStatusDisconnecting:
            return SVPServerStatusDisconnecting;
            break;
        default:
            return SVPServerStatusInvalid;
            break;
    }
}

#pragma mark - Notification

- (void)svpConnectorServerStatusDidChanged:(NSNotification *)notification {
    
    if ([self.delegate respondsToSelector:@selector(svpServerStatusDidChange:)]) {
        [self.delegate svpServerStatusDidChange:[self getCurrentSVPServerStatus]];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Keychain * You can change serviceID if you need
#define kKeychainServiceID @"server002"

// got from: http://useyourloaf.com/blog/2010/03/29/simple-iphone-keychain-access.html

- (NSMutableDictionary *)buildDefaultDictionaryForIdentity:(NSString*)identifier {
    
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    searchDictionary[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    searchDictionary[(__bridge id)kSecAttrGeneric] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecAttrAccount] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecAttrService] = kKeychainServiceID;
    
    return searchDictionary;
}

// 根据 identifier 获取钥匙串中的数据
- (NSData *)getDataInKeychainFromIdentifier:(NSString *)identifier returnReference:(BOOL)referenceOnly {
    
    // get default dictionary
    NSMutableDictionary *dict = [self buildDefaultDictionaryForIdentity:identifier];
    
    // set for searching
    dict[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    
    // need reference
    if (referenceOnly) {
        dict[(__bridge id)kSecReturnPersistentRef] = @YES;
    } else {
        dict[(__bridge id)kSecReturnData] = @YES;
    }
    
    // create result object
    CFTypeRef result = NULL;
    
    // Get result
    SecItemCopyMatching((__bridge CFDictionaryRef)dict, &result);
    
    // return result
    return (__bridge_transfer NSData *)result;
}

// 根据 identifier 获取钥匙串中的字符串数据
- (NSString*)getStringInKeychainFromIdentifier:(NSString*)identifier {
    
    NSData *keychainData = [self getDataInKeychainFromIdentifier:identifier returnReference:NO];
    return [[NSString alloc] initWithData:keychainData encoding:NSUTF8StringEncoding];
}

// 根据 identifier 获取钥匙串中的二进制数据
- (NSData *)getDataReferenceInKeychainFromIdentifier:(NSString *)identifier {
    
    return [self getDataInKeychainFromIdentifier:identifier returnReference:YES];
}

/// 设置钥匙串中的数据
- (BOOL)setKeychainWithString:(NSString*)string forIdentifier:(NSString*)identifier {
    
    NSMutableDictionary *searchDictionary = [self buildDefaultDictionaryForIdentity:identifier];
    NSData *keychainValue = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    if ([self getDataReferenceInKeychainFromIdentifier:identifier] == nil) {
        [searchDictionary setObject:keychainValue forKey:(__bridge id)kSecValueData];
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)searchDictionary, NULL);
        if (status == errSecSuccess) {
            return YES;
        } else {
            return NO;
        }
    } else {
        NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
        [updateDictionary setObject:keychainValue forKey:(__bridge id)kSecValueData];
        OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary, (__bridge CFDictionaryRef)updateDictionary);
        if (status == errSecSuccess) {
            return YES;
        } else {
            return NO;
        }
    }
}
@end
