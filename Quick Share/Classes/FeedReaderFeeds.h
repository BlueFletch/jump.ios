//
//  FeedReaderFeeds.h
//  QuickShare
//
//  Created by lilli on 8/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedReaderSummary.h"

@interface FeedReaderFeeds : UIViewController 
{
    IBOutlet UIButton *feedButton;
    IBOutlet UITextField *feedAdder;
}

- (IBAction)janrainBlogSelected:(id)sender;
@end