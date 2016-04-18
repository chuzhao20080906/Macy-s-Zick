//
//  ViewController.m
//  macy_chuzhao
//
//  Created by Zick on 4/18/16.
//  Copyright © 2016 Zick. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"



@interface ViewController ()
{
    NSMutableArray *jsonarray;
    BOOL flag;
}
@property (strong, nonatomic) IBOutlet UITableView *tbl_view;
@property (strong, nonatomic) IBOutlet UISearchBar *searchbar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    flag=false;
    jsonarray =[[NSMutableArray alloc]init];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([[[jsonarray firstObject] valueForKey:@"lfs"] count]) {
        return [[[jsonarray firstObject] valueForKey:@"lfs"] count];
    }
    else
        return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (![[[jsonarray firstObject] valueForKey:@"lfs"] count]&&flag) {
        cell.textLabel.text=@"please search different keyword.";
    }
    else{
    cell.textLabel.text=[[[[jsonarray firstObject] valueForKey:@"lfs"] objectAtIndex:indexPath.row] valueForKey:@"lf"];
    }
    
    
    
    return cell;
}

-(void)AFNetworkingGetData:(NSString *) urlString{
    flag=true;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            
                id resultData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
            jsonarray = [NSMutableArray arrayWithArray:resultData];

            dispatch_async(dispatch_get_main_queue(),^{ //change the UI in the main queue
                [self.searchbar resignFirstResponder];
                [MBProgressHUD hideHUDForView:self.view animated:YES]; //hide the MBProgressHUD.
                [_tbl_view setHidden:NO];
                [self.tbl_view reloadData]; // reload the tableview in main_queue.
            });
        }
    }];
    [dataTask resume];
}
#pragma mark delegate for search bar
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if ([self isAlphaNumericOnly:searchBar.text]) {
        [self AFNetworkingGetData:[NSString stringWithFormat:@"http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=%@",searchBar.text]];
    }
    else
    {
        [self AFNetworkingGetData:@"http://www.nactem.ac.uk/software/acromine/dictionary.py?sf="];
    }
    [self.searchbar resignFirstResponder];
    
    
}
-(BOOL)isAlphaNumericOnly:(NSString *)input
{
    NSString *alphaNum = @"[a-zA-Z]+";
    NSPredicate *regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", alphaNum];
    
    return [regexTest evaluateWithObject:input];
}



@end
