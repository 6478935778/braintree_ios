#import "BraintreeDemoCustomMultiPayViewController.h"
#import <BraintreeCard/BraintreeCard.h>
#import <BraintreeUI/BraintreeUI.h>
#import <PureLayout/ALView+PureLayout.h>

@interface BraintreeDemoCustomMultiPayViewController ()
@property(nonatomic, strong) BTUICardFormView *cardForm;
@property (nonatomic, strong) UINavigationController *cardFormNavigationViewController;
@property (nonatomic, weak) UIBarButtonItem *saveButton;
@end

@implementation BraintreeDemoCustomMultiPayViewController

#pragma mark - Lifecycle & Setup

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Custom Payment Button";
}

- (UIView *)paymentButton {
    UIView *view = [[UIView alloc] initForAutoLayout];

    UIButton *venmoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    venmoButton.translatesAutoresizingMaskIntoConstraints = NO;
    venmoButton.titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter" size:[UIFont systemFontSize]];
    venmoButton.backgroundColor = [[BTUI braintreeTheme] venmoPrimaryBlue];
    [venmoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [venmoButton setTitle:@"Venmo" forState:UIControlStateNormal];

    UIButton *payPalButton = [UIButton buttonWithType:UIButtonTypeSystem];
    payPalButton.translatesAutoresizingMaskIntoConstraints = NO;
    payPalButton.titleLabel.font = [UIFont fontWithName:@"GillSans-BoldItalic" size:[UIFont systemFontSize]];
    payPalButton.backgroundColor = [[BTUI braintreeTheme] palBlue];
    [payPalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [payPalButton setTitle:@"PayPal" forState:UIControlStateNormal];

    UIButton *cardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cardButton.translatesAutoresizingMaskIntoConstraints = NO;
    cardButton.backgroundColor = [UIColor bt_colorFromHex:@"DDDECB" alpha:1.0f];
    [cardButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cardButton setTitle:@"💳" forState:UIControlStateNormal];

    [venmoButton addTarget:self action:@selector(tappedVenmo:) forControlEvents:UIControlEventTouchUpInside];
    [payPalButton addTarget:self action:@selector(tappedPayPal:) forControlEvents:UIControlEventTouchUpInside];
    [cardButton addTarget:self action:@selector(tappedCard:) forControlEvents:UIControlEventTouchUpInside];

    [view addSubview:payPalButton];
    [view addSubview:venmoButton];
    [view addSubview:cardButton];

    [venmoButton autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:payPalButton];
    [payPalButton autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:cardButton];

    [venmoButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [venmoButton autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:payPalButton];
    [payPalButton autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:cardButton];
    [cardButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];

    [venmoButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [venmoButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [payPalButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [payPalButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [cardButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [cardButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];

    [view autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:venmoButton];

    return view;
}

#pragma mark - Actions

- (IBAction)tappedVenmo:(__unused UIButton *)button {
    [self tokenizeType:@"Venmo"];
}

- (IBAction)tappedPayPal:(__unused UIButton *)button {
    [self tokenizeType:@"PayPal"];
}

- (IBAction)tappedCard:(UIButton *)button {
    self.cardForm = [[BTUICardFormView alloc] initForAutoLayout];
    self.cardForm.optionalFields = BTUICardFormOptionalFieldsAll;

    UIViewController *cardFormViewController = [[UIViewController alloc] init];
    cardFormViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                            target:self
                                                                                                            action:@selector(cancelCardVC)];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                    target:self
                                                                    action:@selector(saveCardVC)];
    cardFormViewController.navigationItem.rightBarButtonItem = saveButton;
    cardFormViewController.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
    cardFormViewController.navigationItem.rightBarButtonItem.enabled = NO;
    self.saveButton = saveButton;

    cardFormViewController.title = @"💳";
    [cardFormViewController.view addSubview:self.cardForm];
    cardFormViewController.view.backgroundColor = button.backgroundColor;

    [self.cardForm autoPinToTopLayoutGuideOfViewController:cardFormViewController withInset:40];
    [self.cardForm autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.cardForm autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];

    self.cardFormNavigationViewController = [[UINavigationController alloc] initWithRootViewController:cardFormViewController];

    [self.cardForm addObserver:self forKeyPath:@"valid" options:0 context:NULL];

    [self presentViewController:self.cardFormNavigationViewController animated:YES completion:nil];
}

#pragma mark - Private methods

- (void)tokenizeType:(NSString *)type {
    [[BTTokenizationService sharedService] tokenizeType:type options:nil withAPIClient:self.apiClient completion:^(id<BTTokenized>  _Nonnull tokenization, NSError * _Nonnull error) {
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
}

- (void)cancelCardVC {
    [self.cardForm removeObserver:self forKeyPath:@"valid"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveCardVC {
    [self cancelCardVC];

    BTCardTokenizationRequest *request = [[BTCardTokenizationRequest alloc] init];
    request.number = self.cardForm.number;
    request.expirationMonth = self.cardForm.expirationMonth;
    request.expirationYear = self.cardForm.expirationYear;
    request.cvv = self.cardForm.cvv;
    request.postalCode = self.cardForm.postalCode;
    request.shouldValidate = NO;

    BTCardClient *cardClient = [[BTCardClient alloc] initWithAPIClient:self.apiClient];
    [cardClient tokenizeCard:request completion:^(BTTokenizedCard * _Nullable tokenizedCard, NSError * _Nullable error) {
        if (tokenizedCard) {
            self.progressBlock(@"Got a nonce 💎!");
            NSLog(@"%@", [tokenizedCard debugDescription]);
            self.completionBlock(tokenizedCard);
        } else if (error) {
            self.progressBlock(error.localizedDescription);
        } else {
            self.progressBlock(@"Canceled 🔰");
        }
    }];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"valid"]) {
        self.saveButton.enabled = self.cardForm.valid;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
