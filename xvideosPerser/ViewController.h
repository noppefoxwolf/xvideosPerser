//
//  ViewController.h
//  xvideosPerser
//
//  Created by Tomoya_Hirano on 2013/09/01.
//  Copyright (c) 2013年 Tomoya_Hirano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMLParser.h"
#import "ImageStore.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    IBOutlet UITableView *MainTable;
    NSMutableArray* statuses;
    ImageStore*imageStore;
    IBOutlet UISegmentedControl *Undet_segment;
}
- (IBAction)SegmentRef:(id)sender;

@end
