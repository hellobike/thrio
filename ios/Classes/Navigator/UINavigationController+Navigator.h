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

#import <UIKit/UIKit.h>
#import "ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (Navigator)

- (void)thrio_pushUrl:(NSString *)url
               params:(id _Nullable)params
             animated:(BOOL)animated
       fromEntrypoint:(NSString * _Nullable)entrypoint
               result:(ThrioNumberCallback _Nullable)result
         poppedResult:(ThrioIdCallback _Nullable)poppedResult;

- (BOOL)thrio_notifyUrl:(NSString *)url
                  index:(NSNumber * _Nullable)index
                   name:(NSString *)name
                 params:(id _Nullable)params;

- (void)thrio_popParams:(id _Nullable)params
               animated:(BOOL)animated
                 result:(ThrioBoolCallback _Nullable)result;

- (void)thrio_popToUrl:(NSString *)url
                 index:(NSNumber * _Nullable)index
              animated:(BOOL)animated
                result:(ThrioBoolCallback _Nullable)result;

- (void)thrio_removeUrl:(NSString *)url
                  index:(NSNumber * _Nullable)index
               animated:(BOOL)animated
                 result:(ThrioBoolCallback _Nullable)result;

- (void)thrio_didPushUrl:(NSString *)url index:(NSNumber *)index;

- (void)thrio_didPopUrl:(NSString *)url index:(NSNumber *)index;

- (void)thrio_didPopToUrl:(NSString *)url index:(NSNumber *)index;

- (void)thrio_didRemoveUrl:(NSString *)url index:(NSNumber *)index;

- (NSNumber * _Nullable)thrio_lastIndex;

- (NSNumber * _Nullable)thrio_getLastIndexByUrl:(NSString *)url;

- (NSArray *)thrio_getAllIndexByUrl:(NSString *)url;

- (BOOL)thrio_ContainsUrl:(NSString *)url;

- (BOOL)thrio_ContainsUrl:(NSString *)url index:(NSNumber *)index;

- (UIViewController *_Nullable)getViewControllerByUrl:(NSString *)url
                                                index:(NSNumber * _Nullable)index;

- (void)thrio_didShowViewController:(UIViewController *)viewController
                           animated:(BOOL)animated;

/// 手势触发的当前正要被pop的`UIViewController`
///
@property (nonatomic, strong, nullable) UIViewController *thrio_popingViewController;

@end

NS_ASSUME_NONNULL_END
