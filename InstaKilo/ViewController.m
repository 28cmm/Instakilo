//
//  ViewController.m
//  InstaKilo
//
//  Created by Yilei Huang on 2019-01-23.
//  Copyright © 2019 Joshua Fanng. All rights reserved.
//

#import "ViewController.h"
#import "MyCollectionViewCell.h"
#import "MyHeader.h"
#import "MyFooter.h"
#import "Imagee.h"
#import "ImageCell.h"



@interface ViewController () <UICollectionViewDataSource,UICollectionViewDragDelegate,UICollectionViewDropDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSMutableArray *infoArray;
@property UICollectionViewFlowLayout *normalLayout;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.collectionView.dragInteractionEnabled = YES;
    self.collectionView.dataSource = self;
    self.collectionView.dropDelegate = self;
    self.collectionView.dragDelegate = self;
    
    self.infoArray = [@[
                        [[Imagee alloc]initWithImage:[UIImage imageNamed:@"1"]],
                        [[Imagee alloc]initWithImage:[UIImage imageNamed:@"2"]],
                        [[Imagee alloc]initWithImage:[UIImage imageNamed:@"3"]],
                        [[Imagee alloc]initWithImage:[UIImage imageNamed:@"4"]],
                        [[Imagee alloc]initWithImage:[UIImage imageNamed:@"5"]],
                        [[Imagee alloc]initWithImage:[UIImage imageNamed:@"6"]],
                        [[Imagee alloc]initWithImage:[UIImage imageNamed:@"7"]],
                        [[Imagee alloc]initWithImage:[UIImage imageNamed:@"8"]],
                        [[Imagee alloc]initWithImage:[UIImage imageNamed:@"9"]],
                        [[Imagee alloc]initWithImage:[UIImage imageNamed:@"10"]],
                        [[Imagee alloc]initWithImage:[UIImage imageNamed:@"11"]],
                        [[Imagee alloc]initWithImage:[UIImage imageNamed:@"12"]],
                        ]mutableCopy];
    [self setNormalLayout];
    self.collectionView.collectionViewLayout = self.normalLayout;
}
-(NSArray<UIDragItem*>*)collectionView:(UICollectionView *)collectionView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath{
    NSString *imageName =[self.infoArray[indexPath.section] objectAtIndex:indexPath.item];
    NSLog(@"this is bugged %@",imageName);
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:imageName];
    UIDragItem *dragItem = [[UIDragItem alloc] initWithItemProvider:itemProvider];
    dragItem.localObject = imageName;
    return @[dragItem];
}



- (BOOL)collectionView:(UICollectionView *)collectionView canHandleDropSession:(id<UIDropSession>)session {
    return [session canLoadObjectsOfClass:[NSString class]];
}

// 拖动过程中不断反馈item位置。
- (UICollectionViewDropProposal *)collectionView:(UICollectionView *)collectionView dropSessionDidUpdate:(id<UIDropSession>)session withDestinationIndexPath:(NSIndexPath *)destinationIndexPath {
    UICollectionViewDropProposal *dropProposal;
    if (session.localDragSession) {
        // 拖动手势源自同一app。
        dropProposal = [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationMove intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
    } else {
        // 拖动手势源自其它app。
        dropProposal = [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationCopy intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
    }
    return dropProposal;
}

- (void)collectionView:(UICollectionView *)collectionView performDropWithCoordinator:(id<UICollectionViewDropCoordinator>)coordinator {
    // 如果coordinator.destinationIndexPath存在，直接返回；如果不存在，则返回（0，0)位置。
    NSIndexPath *destinationIndexPath = coordinator.destinationIndexPath ? coordinator.destinationIndexPath : [NSIndexPath indexPathForItem:0 inSection:0];
    
    // 在collectionView内，重新排序时只能拖动一个cell。
    if (coordinator.items.count == 1 && coordinator.items.firstObject.sourceIndexPath) {
        NSIndexPath *sourceIndexPath = coordinator.items.firstObject.sourceIndexPath;
        
        // 将多个操作合并为一个动画。
        [collectionView performBatchUpdates:^{
            // 将拖动内容从数据源删除，插入到新的位置。
            NSString *imageName = coordinator.items.firstObject.dragItem.localObject;
            [self.infoArray[sourceIndexPath.section] removeObjectAtIndex:sourceIndexPath.item];
            [self.infoArray[destinationIndexPath.section] insertObject:imageName atIndex:destinationIndexPath.item];
            
            // 更新collectionView。
            [collectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
        } completion:nil];
        
        // 以动画形式移动cell。
        [coordinator dropItem:coordinator.items.firstObject.dragItem toItemAtIndexPath:destinationIndexPath];
    }
}
- (IBAction)tapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [sender locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        NSLog(@"%@",indexPath);
        if (indexPath)
        {
            int i=indexPath.row;
            
            [self.collectionView performBatchUpdates:^{
                [self.infoArray removeObjectAtIndex:i];
                NSIndexPath *indexPath =[NSIndexPath indexPathForRow:i inSection:0];
                [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
                
            } completion:^(BOOL finished) {
                
            }];
            NSLog(@"Image was double tapped");
        }
    }
}


-(void)setNormalLayout{
    self.normalLayout =[UICollectionViewFlowLayout new];
    self.normalLayout.itemSize = CGSizeMake(195, 195);
    self.normalLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.normalLayout.minimumInteritemSpacing = 0; //horizontal
    //vertical
    self.normalLayout.minimumLineSpacing =5;
    self.normalLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.normalLayout.headerReferenceSize = CGSizeMake(self.collectionView.frame.size.width, 25);
    self.normalLayout.footerReferenceSize = CGSizeMake(self.collectionView.frame.size.width, 15);
}

//how many section
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
    
}

//number of box in each section
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    switch (section) {
        case 0:           // For section 0...
            return self.infoArray.count;     // ...we have 5 items
       default:
            return self.infoArray.count;
    }
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView
  cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSString *cellId = @"myCell";  // Reuse identifier
    switch (indexPath.section) {
        case 0:  // Section 0....
            cellId = @"myImage";  // ...use "myCell"
            break;
        case 1:
            cellId = @"myBlueCell";
            break;

        default:
            cellId = @"myBlueCell";
            break;
    }
    
    // Ask collection view to give us a cell that we can use to populate our data
    ImageCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellId
                                                                                forIndexPath:indexPath];
    
    // Cell will display the section and row number
    NSString *myIndex = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    cell.imageView.image =[UIImage imageNamed:myIndex];
    
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        MyHeader *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                           withReuseIdentifier:@"MyHeaderView"
                                                                                  forIndexPath:indexPath];
        switch (indexPath.section) {
            case 0:
                headerView.headerLabel.text = @"Normal photo";
                return headerView;

            default:
                headerView.headerLabel.text = @"Normal photo";
                 return headerView;
        }
    }
    else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        MyFooter *footerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                           withReuseIdentifier:@"MyFooterView"
                                                                                  forIndexPath:indexPath];
        switch (indexPath.section) {
            case 0:
                footerView.myFooter.text = @"Normal photo footer";
                return footerView;
                
            default:
                footerView.myFooter.text = @"Normal photo footer";
                return footerView;
        }
    }
    else {
        return nil;
    }
}




@end
