#import "BraintreeDemoBTPaymentButtonViewController.h"
#import <BraintreeCard/BraintreeCard.h>
#import <BraintreeUI/BraintreeUI.h>
#import <PureLayout/ALView+PureLayout.h>

@interface BraintreeDemoBTPaymentButtonViewController () <BTPaymentDriverDelegate>
@end

@implementation BraintreeDemoBTPaymentButtonViewController

- (UIView *)paymentButton {
    BTPaymentButton *paymentButton = [[BTPaymentButton alloc] initWithAPIClient:self.apiClient completion:^(id<BTTokenized> tokenization, NSError *error) {
        if (tokenization) {
            self.progressBlock(@"Got a nonce 💎!");
            NSLog(@"%@", [tokenization debugDescription]);
            self.completionBlock(tokenization);
        } else if (error) {
            self.progressBlock(error.localizedDescription);
        } else {
            self.progressBlock(@"Canceled 🔰");
        }
    }];
    paymentButton.delegate = self;
    return paymentButton;
}

- (void)paymentDriverWillPerformAppSwitch:(id)driver {
    self.progressBlock(@"Will perform app switch");
}

- (void)paymentDriver:(id)driver didPerformAppSwitchToTarget:(BTAppSwitchTarget)target {
    self.progressBlock(@"Did perform app switch");
}

- (void)paymentDriverWillProcessPaymentInfo:(id)driver {
    self.progressBlock(@"Processing payment info...");
}

@end
