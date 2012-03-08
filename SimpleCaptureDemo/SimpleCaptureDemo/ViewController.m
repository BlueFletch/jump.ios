//
//  ViewController.m
//  SimpleCaptureDemo
//
//  Created by lilli on 02/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLog(...)
#endif

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)


#import "ViewController.h"

int factorial(int n) {
    DLog(@"Calculating the factorial of %d", n);

    if (n == 1) {
        DLog(@"Base case reached; returning 1");
        return 1;
    }
    else
    {
        DLog(@"Need to calculate %d * factorial(%d - 1)", n, n);
        DLog(@"Drilling down to find the answer to factorial(%d - 1)", n);

        int subanswer = factorial(n - 1);
        int answer = n * subanswer;

        DLog(@"Going back up");
        DLog(@"factorial(%d - 1) = %d", n, subanswer);
        DLog(@"factorial(%d) = %d", n, answer);

        return answer;
    }

}


@interface ViewController ()
@property (strong) SharedData *sharedData;
@end

@implementation ViewController
@synthesize sharedData;
@synthesize currentUserLabel;
@synthesize currentUserProviderIcon;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sharedData = [SharedData sharedData];

    int ourFactorial = factorial(15);

    DLog(@"Answer: %d", ourFactorial);

    if (sharedData.currentDisplayName)
        currentUserLabel.text = [NSString stringWithFormat:@"Current user: %@", sharedData.currentDisplayName];

    if (sharedData.currentProvider)
        currentUserProviderIcon.image = [UIImage imageNamed:
                     [NSString stringWithFormat:@"icon_%@_30x30@2x.png", sharedData.currentProvider]];
}

- (IBAction)browseButtonPressed:(id)sender
{
    UserDrillDownViewController *drillDown =
                [[UserDrillDownViewController alloc] initWithNibName:@"UserDrillDownViewController"
                                                              bundle:[NSBundle mainBundle]
                                                    forCaptureObject:sharedData.captureUser
                                                 captureParentObject:nil
                                                              andKey:@"CaptureUser"];

    [[self navigationController] pushViewController:drillDown animated:YES];

//    UserDrillDownViewController *viewController = [[UserDrillDownViewController alloc]
//            initWithNibName:@"UserDrillDownViewController"
//                     bundle:[NSBundle mainBundle]
//              andDataObject:sharedData.captureUser forKey:@"CaptureUser"];
//
//    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)updateButtonPressed:(id)sender
{
    CaptureNewUserViewController *viewController = [[CaptureNewUserViewController alloc]
            initWithNibName:@"CaptureNewUserViewController" bundle:[NSBundle mainBundle]];

    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)deleteButtonPressed:(id)sender
{

}

- (IBAction)signInButtonPressed:(id)sender
{
    NSDictionary *customInterface = [NSDictionary dictionaryWithObject:self.navigationController
                                                                forKey:kJRApplicationNavigationController];

    [sharedData startAuthenticationWithCustomInterface:customInterface forDelegate:self];
}

- (void)engageSignInDidSucceed
{
    currentUserLabel.text         =
            [NSString stringWithFormat:@"Current user: %@", sharedData.currentDisplayName];
    currentUserProviderIcon.image =
            [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@_30x30@2x.png", sharedData.currentProvider]];
}

- (void)captureSignInDidSucceed
{
    if (sharedData.creationToken)
    {
        CaptureNewUserViewController *viewController = [[CaptureNewUserViewController alloc]
                initWithNibName:@"CaptureNewUserViewController" bundle:[NSBundle mainBundle]];

        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)engageSignInDidFailWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:error ? @"Error" : @"Canceled"
                                                        message:error ? [error description] : @"Authentication was canceled"
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)captureSignInDidFailWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end