// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.


#import "NavigatorReceiveChannel.h"
#import "ThrioNavigator.h"
#import "ThrioNavigator+Internal.h"
#import "ThrioNavigator+NavigatorBuilder.h"
#import "UINavigationController+Navigator.h"
#import "UINavigationController+HotRestart.h"
#import "UINavigationController+PopDisabled.h"
#import "UINavigationController+Navigator.h"
#import "NavigatorFlutterEngineFactory.h"
#import "ThrioLogger.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorReceiveChannel ()

@property (nonatomic, strong) ThrioChannel *channel;

@property (nonatomic, copy, nullable) ThrioIdCallback readyBlock;

@end

@implementation NavigatorReceiveChannel

- (instancetype)initWithChannel:(ThrioChannel *)channel {
  self = [super init];
  if (self) {
    _channel = channel;
    [self _onReady];
    [self _onPush];
    [self _onNotify];
    [self _onPop];
    [self _onPopTo];
    [self _onRemove];
    [self _onDidPush];
    [self _onDidPop];
    [self _onDidPopTo];
    [self _onDidRemove];
    [self _onLastIndex];
    [self _onGetAllIndex];
    [self _onSetPopDisabled];
    [self _onHotRestart];
    [self _onRegisterUrls];
    [self _onUnregisterUrls];
  }
  return self;
}

- (void)setReadyBlock:(ThrioIdCallback _Nullable)block {
  _readyBlock = block;
}

#pragma mark - on channel methods

- (void)_onReady {
  __weak typeof(self) weakself = self;
  [_channel registryMethodCall:@"ready"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioIdCallback _Nullable result) {
    __strong typeof(self) strongSelf = weakself;
    if (strongSelf.readyBlock) {
      ThrioLogV(@"on ready: %@", strongSelf.channel.entrypoint);
      strongSelf.readyBlock(strongSelf.channel.entrypoint);
      strongSelf.readyBlock = nil;
    }
  }];
}

- (void)_onPush {
  __weak typeof(self) weakself = self;
  [_channel registryMethodCall:@"push"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioIdCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    if (url.length < 1) {
      if (result) {
        result(nil);
      }
      return;
    }
    id params = [arguments[@"params"] isKindOfClass:NSNull.class] ? nil : arguments[@"params"];
    BOOL animated = [arguments[@"animated"] boolValue];
    ThrioLogV(@"on push: %@", url);
    __strong typeof(self) strongSelf = weakself;
    [ThrioNavigator.navigationController thrio_pushUrl:url
                                                params:params
                                              animated:animated
                                        fromEntrypoint:strongSelf.channel.entrypoint
                                                result:^(NSNumber *idx) { result(idx); }
                                          poppedResult:nil];
  }];
}

- (void)_onNotify {
  [_channel registryMethodCall:@"notify"
                       handler:^void(NSDictionary<NSString *,id> * arguments,
                                     ThrioIdCallback _Nullable result) {
    NSString *name = arguments[@"name"];
    if (name.length < 1) {
      if (result) {
        result(@NO);
      }
      return;
    }
    NSString *url = arguments[@"url"];
    if (url.length < 1) {
      if (result) {
        result(@NO);
      }
      return;
    }
    NSNumber *index = [arguments[@"index"] isKindOfClass:NSNull.class] ? nil : arguments[@"index"];
    id params = [arguments[@"params"] isKindOfClass:NSNull.class] ? nil : arguments[@"params"];
    [ThrioNavigator notifyUrl:url index:index name:name params:params result:^(BOOL r) {
      if (result) {
        result(@(r));
      }
    }];
  }];
}

- (void)_onPop {
  [_channel registryMethodCall:@"pop"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioIdCallback _Nullable result) {
    BOOL animated = [arguments[@"animated"] boolValue];
    id params = [arguments[@"params"] isKindOfClass:NSNull.class] ? nil : arguments[@"params"];
    
    ThrioLogV(@"on pop");

    [ThrioNavigator popParams:params animated:animated result:^(BOOL r) {
      if (result) {
        result(@(r));
      }
    }];
  }];
}

- (void)_onPopTo {
  [_channel registryMethodCall:@"popTo"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioIdCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    if (url.length < 1) {
      if (result) {
        result(@NO);
      }
      return;
    }
    NSNumber *index = [arguments[@"index"] isKindOfClass:NSNull.class] ? nil : arguments[@"index"];
    BOOL animated = [arguments[@"animated"] boolValue];
    
    ThrioLogV(@"on popTo: %@.%@", url, index);

    [ThrioNavigator popToUrl:url index:index animated:animated result:^(BOOL r) {
      if (result) {
        result(@(r));
      }
    }];
  }];
}

- (void)_onRemove {
  [_channel registryMethodCall:@"remove"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioIdCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    NSNumber *index = [arguments[@"index"] isKindOfClass:NSNull.class] ? nil : arguments[@"index"];
    BOOL animated = [arguments[@"animated"] boolValue];

    ThrioLogV(@"on remove: %@.%@", url, index);

    [ThrioNavigator removeUrl:url index:index animated:animated result:^(BOOL r) {
      if (result) {
        result(@(r));
      }
    }];
  }];
}

- (void)_onLastIndex {
  [_channel registryMethodCall:@"lastIndex"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioIdCallback _Nullable result) {
    if (result) {
      NSString *url = arguments[@"url"];
      if (url.length < 1) {
        result([ThrioNavigator lastIndex]);
      } else {
        result([ThrioNavigator getLastIndexByUrl:url]);
      }
    }
  }];
}

- (void)_onGetAllIndex {
  [_channel registryMethodCall:@"allIndex"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioIdCallback _Nullable result) {
     NSString *url = arguments[@"url"];
     if (result) {
       result([ThrioNavigator getAllIndexByUrl:url]);
     }
  }];
}

- (void)_onDidPush {
  [_channel registryMethodCall:@"didPush"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioIdCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    NSNumber *index = arguments[@"index"];

    ThrioLogV(@"on didPush: %@.%@", url, index);

    [ThrioNavigator.navigationController thrio_didPushUrl:url index:index];
  }];
}

- (void)_onDidPop {
  [_channel registryMethodCall:@"didPop"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioIdCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    NSNumber *index = arguments[@"index"];

    ThrioLogV(@"on didPop: %@.%@", url, index);

    [ThrioNavigator.navigationController thrio_didPopUrl:url index:index];
  }];
}

- (void)_onDidPopTo {
  [_channel registryMethodCall:@"didPopTo"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioIdCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    NSNumber *index = arguments[@"index"];

    ThrioLogV(@"on didPopTo: %@.%@", url, index);

    [ThrioNavigator.navigationController thrio_didPopToUrl:url index:index];
  }];
}

- (void)_onDidRemove {
  [_channel registryMethodCall:@"didRemove"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioIdCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    NSNumber *index = arguments[@"index"];

    ThrioLogV(@"on didRemove: %@.%@", url, index);

    [ThrioNavigator.navigationController thrio_didRemoveUrl:url index:index];
  }];
}

- (void)_onSetPopDisabled {
  [_channel registryMethodCall:@"setPopDisabled"
                       handler:^void(NSDictionary<NSString *,id> * arguments,
                                     ThrioIdCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    NSNumber *index = arguments[@"index"];
    BOOL disabled = [arguments[@"disabled"] boolValue];
    ThrioLogV(@"setPopDisabled: %@.%@ %@", url, index, @(disabled));
    [ThrioNavigator.navigationController thrio_setPopDisabledUrl:url
                                                           index:index
                                                        disabled:disabled];
  }];
}

- (void)_onHotRestart {
  [_channel registryMethodCall:@"hotRestart"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioIdCallback _Nullable result) {
    if (!ThrioNavigator.isMultiEngineEnabled) {
      [ThrioNavigator.navigationController thrio_hotRestart:^(BOOL r) {
        result(@(r));
      }];
    }
  }];
}

- (void)_onRegisterUrls {
  [_channel registryMethodCall:@"registerUrls"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioIdCallback _Nullable result) {
    NSArray *urls = arguments[@"urls"];
    [NavigatorFlutterEngineFactory.shared registerFlutterUrls:urls];
  }];
}

- (void)_onUnregisterUrls {
  [_channel registryMethodCall:@"unregisterUrls"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioIdCallback _Nullable result) {
    NSArray *urls = arguments[@"urls"];
    [NavigatorFlutterEngineFactory.shared unregisterFlutterUrls:urls];
  }];
}

@end

NS_ASSUME_NONNULL_END
