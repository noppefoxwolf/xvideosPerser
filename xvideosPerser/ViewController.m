//
//  ViewController.m
//  xvideosPerser
//
//  Created by Tomoya_Hirano on 2013/09/01.
//  Copyright (c) 2013年 Tomoya_Hirano. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    //imagestoreの初期化
    imageStore = [[ImageStore alloc] initWithDelegate:self];
    
    
    //データベースの生成
    [self DatabaseRefresh];
    //表示
    [MainTable reloadData];
}

-(void)DatabaseRefresh{
    //データベースの初期化
    statuses = [NSMutableArray new];
    switch (Undet_segment.selectedSegmentIndex) {
        case 0:{
            [self makeVideosData:@"http://jp.xvideos.com/"];
            break;
        }case 1:{
            [self makeVideosData:@"http://jp.xvideos.com/c/asian_woman-32/"];
            break;
        }case 2:{
            [self makeVideosData:@"http://jp.xvideos.com/hits/"];
            break;
        }
        default:
            break;
    }
    [MainTable reloadData];
}

- (IBAction)SegmentRef:(id)sender {
    [self DatabaseRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getvideoData:(NSString*)url{
    NSString*html = [self URLtoHTML:url];
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
        return;
    }
    HTMLNode *bodyNode = [parser body];
    NSArray *divNodes = [bodyNode findChildTags:@"div"];
    for (HTMLNode *divNode in divNodes) {
        if ([[divNode getAttributeNamed:@"id"] isEqualToString:@"content"]) {
            //NSLog(@"%@",[divNode rawContents]);
            NSArray *scriptNodes = [divNode findChildTags:@"script"];
            for (HTMLNode *scriptNode in scriptNodes) {
                //NSLog(@"%@",[scriptNode contents]);
                NSString *str2 = [[scriptNode contents] stringByReplacingOccurrencesOfString:@"mobileReplacePlayerDivTwoQual(" withString:@""];
                str2 = [str2 stringByReplacingOccurrencesOfString:@");" withString:@""];
                str2 = [str2 stringByReplacingOccurrencesOfString:@"'" withString:@""];
                str2 = [str2 stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSArray *apiData = [str2 componentsSeparatedByString:@","];
                NSLog(@"%@",[apiData objectAtIndex:2]);
                
                
                NSURL  *movieURL = [NSURL URLWithString:[apiData objectAtIndex:2]];
              
                
                MPMoviePlayerViewController *mymovie = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
                [self presentMoviePlayerViewControllerAnimated:mymovie];

                
            }
        }
    }
}

- (void)makeVideosData:(NSString*)url{
    NSString*html = [self URLtoHTML:url];
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
        return;
    }
    
    HTMLNode *bodyNode = [parser body];
    
    NSArray *divNodes = [bodyNode findChildTags:@"div"];
    for (HTMLNode *divNode in divNodes) {
        if ([[divNode getAttributeNamed:@"class"] isEqualToString:@"thumbBlock"]) {
            NSMutableDictionary*status = [NSMutableDictionary new];
            
            //divタグ一覧
            NSArray *divNodes2 = [divNode findChildTags:@"div"];
            for (HTMLNode *divNode2 in divNodes2) {
                if ([[divNode2 getAttributeNamed:@"class"] isEqualToString:@"thumb"]) {
                    NSArray *imgNodes = [divNode2 findChildTags:@"img"];
                    for (HTMLNode *imgNode in imgNodes) {
                        //NSLog(@"%@", [imgNode getAttributeNamed:@"src"]); //サムネURL
                        [status setObject:[imgNode getAttributeNamed:@"src"] forKey:@"thmburl"];
                    }
                    NSArray *aNodes = [divNode2 findChildTags:@"a"];
                    for (HTMLNode *aNode in aNodes) {
                        NSString*jumpurl =
                            [NSString stringWithFormat:@"http://jp.xvideos.com%@",[aNode getAttributeNamed:@"href"]];
                        //NSLog(@"%@",jumpurl); //遷移先URL
                        [status setObject:jumpurl forKey:@"url"];
                    }
                }
            }
                
            //pタグ一覧
            NSArray*pNodes = [divNode findChildTags:@"p"];
            for (HTMLNode *pNode in pNodes) {
                
                if ([[pNode getAttributeNamed:@"class"] isEqualToString:@"metadata"]){
                    NSArray *spanNodes = [pNode findChildTags:@"span"];
                    for (HTMLNode *spanNode in spanNodes) {
                        if ([[spanNode getAttributeNamed:@"class"] isEqualToString:@"duration"]) {
                            //NSLog(@"%@", [spanNode contents]); //再生時間
                            [status setObject:[spanNode contents] forKey:@"duration"];
                        }else if ([[spanNode getAttributeNamed:@"class"] isEqualToString:@"bg"]) {
                            //NSLog(@"%@", [spanNode contents]); //評価
                        }
                    }
                }
                
                NSArray *aNodes2 = [pNode findChildTags:@"a"];
                for (HTMLNode *aNode2 in aNodes2) {
                    //NSLog(@"%@",[aNode2 contents]);//タイトル
                    [status setObject:[aNode2 contents] forKey:@"title"];
                }
            }
            
            [statuses addObject:status];
        }
    }
    [parser release];
}

- (NSString*)URLtoHTML:(NSString*)url_str{
    NSString* userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A403 Safari/8536.25";
    NSURL* url = [NSURL URLWithString:url_str];
    NSMutableURLRequest* request = [[[NSMutableURLRequest alloc] initWithURL:url]
                                    autorelease];
    [request addValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    NSString *html= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return html;
}

- (void)dealloc {
    [MainTable release];
    [Undet_segment release];
    [super dealloc];
}

//imagestore delegate
- (void)imageStoreDidGetNewImage:(ImageStore*)sender url:(NSString*)url{
    [MainTable reloadData];
}

//テーブルに含まれるセクションの数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
//セクションに含まれる行の数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return statuses.count;
}

//高さ
-(CGFloat)tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

//行に表示するデータの生成
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell*cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"] autorelease];
    //テーブルのセルの生成
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"]autorelease];
    }
    
    NSDictionary*status = [statuses objectAtIndex:indexPath.row];
    
    UIImageView *thmb = [[[UIImageView alloc] initWithFrame:CGRectMake(1, 1, 180/2, 135/2)] autorelease];
    thmb.image = [imageStore getImage:[status objectForKey:@"thmburl"]];
    [cell.contentView addSubview:thmb];
    
	UILabel *titlelbl = [[[UILabel alloc] initWithFrame:CGRectMake(100,0,220,30)] autorelease];
    titlelbl.font = [UIFont systemFontOfSize:10];
    titlelbl.adjustsFontSizeToFitWidth = YES;
    titlelbl.text = [status objectForKey:@"title"];
    titlelbl.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:titlelbl];
    
    UILabel *durationlbl = [[[UILabel alloc] initWithFrame:CGRectMake(100,30,100,30)] autorelease];
    durationlbl.text = [status objectForKey:@"duration"];
    durationlbl.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:durationlbl];
    
    return cell;
}

//セル選択
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self getvideoData:[[statuses objectAtIndex:indexPath.row] objectForKey:@"url"]];
}


@end
