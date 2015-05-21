//
//  Created by jcampbell on 1/31/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SelectThumbsDataSource.h"
#import "SelectThumbsTableViewCell.h"

@implementation SelectThumbsDataSource

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
  if ([object conformsToProtocol:@protocol(TTPhoto)]) {
    return [SelectThumbsTableViewCell class];

  } else {
    return [super tableView:tableView cellClassForObject:object];
  }
}

- (UITableViewCell*)tableView:(UITableView *)tableView
                    cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    return cell;
}



@end