//
//  MTDealTool.m
//  MT美团模仿
//
//  Created by Nico on 16/9/5.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTDealTool.h"
#import "FMDB.h"
#import "MTDeal.h"
#import "MTConst.h"
@implementation MTDealTool

static FMDatabase *db;

+ (void)initialize
{
    NSString *documentPath=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *filePath=[documentPath stringByAppendingPathComponent:@"db.sqlite"];
    db=[FMDatabase databaseWithPath:filePath];
    if (![db open])
        return;
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_collection_deal (id integer PRIMARY KEY, deal blob NOT NULL, deal_id text NOT NULL)"];
}

+ (NSArray *)dealArrayWithPage:(NSInteger)page
{
    NSMutableArray *dealArray=[NSMutableArray array];
    NSInteger position=limitNum*(page-1);
    FMResultSet *resultSet=[db executeQueryWithFormat:@"SELECT * FROM t_collection_deal ORDER BY id DESC LIMIT %ld,%ld",position,limitNum];
    while (resultSet.next) {
        NSData *dealData=[resultSet dataForColumn:@"deal"];
        MTDeal *deal=[NSKeyedUnarchiver unarchiveObjectWithData:dealData];
        [dealArray addObject:deal];
    }
    return dealArray;
}

+ (void)addDeal:(MTDeal *)deal
{
    NSData *dealData=[NSKeyedArchiver archivedDataWithRootObject:deal];
    [db executeUpdateWithFormat:@"INSERT INTO t_collection_deal(deal,deal_id) VALUES(%@,%@)",dealData,deal.deal_id];
}

+ (void)removeDeal:(MTDeal *)deal
{
    [db executeUpdateWithFormat:@"DELETE FROM t_collection_deal WHERE deal_id=%@",deal.deal_id];
}

+ (NSInteger)countOfDealCollect
{
    FMResultSet *result=[db executeQuery:@"SELECT count(*) AS deal_num FROM t_collection_deal"];
    [result next];
    return [result intForColumn:@"deal_num"];
}

+ (BOOL)isTableContainDeal:(MTDeal *)deal
{
    FMResultSet *result=[db executeQueryWithFormat:@"SELECT count(*) AS deal_exists FROM t_collection_deal WHERE deal_id=%@",deal.deal_id];
    [result next];
    return [result intForColumn:@"deal_exists"]==1;
}
@end
