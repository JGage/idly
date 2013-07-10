//
//  UIAlertView+UITableView.h
//  NewWorld
//
//  Created by Divakar Srinivasan on 10/12/12.
//


#import <UIKit/UIKit.h>

@protocol AlertTableViewDelegate <NSObject>

- (void)didSelectRowAtIndex:(NSInteger)row 
                    section:(NSInteger)section
                withContext:(id)context
                       text:(NSString *)text 
                    andItem:(NSMutableDictionary *)item
                        row:(int)rowSelected;

@end

@interface AlertTableView : UIAlertView <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *myTableView;
    id<AlertTableViewDelegate> caller;
    id context;
    NSArray *data;
    NSMutableDictionary *itemValue;
    int sectionSelected;
    int selectedRow;
	int tableHeight;
    BOOL isModal;
}

- (id)initWithCaller:(id<AlertTableViewDelegate>)_caller
                data:(NSArray*)_data
               title:(NSString*)_title
             context:(id)_context
          dictionary:(NSMutableDictionary *)item
             section:(int)section
                 row:(int)row;

@property(nonatomic, retain) id<AlertTableViewDelegate> caller;
@property(nonatomic, retain) id context;
@property(nonatomic, retain) NSArray *data;
@property(nonatomic, retain) NSMutableDictionary *itemValue;
@property(nonatomic) int sectionSelected;
@property(nonatomic) int selectedRow;
@property(nonatomic) BOOL isModal;

@end

@interface AlertTableView (HIDDEN)

- (void)prepare;

@end