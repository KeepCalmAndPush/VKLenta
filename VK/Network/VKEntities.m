//
//  VKEntities.m
//  BigBookTest
//
//  Created by Андрей Соловьев on 10/11/2018.
//  Copyright © 2018 andrey. All rights reserved.
//

#import "VKEntities.h"
#import "NSString+Utilities.h"

#define pnfs(name) NSStringFromSelector(@selector(name))

@implementation VKJSONObject

- (instancetype)initWithJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary {
    self = [super init];
    
    if (self) {
        [self fillPropertiesWithDictionary:dictionary];
    }
    
    return self;
}

- (void)fillPropertiesWithDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key,
                                                    NSObject * _Nonnull obj,
                                                    BOOL * _Nonnull stop) {
        
        NSString *setterName = [NSString stringWithFormat:@"set%@:", key.stringWithUppercasedFirstCharacter];
        SEL setter = NSSelectorFromString(setterName);
        
        if ([self respondsToSelector:setter]) {
            obj = [self preparedObject:obj forKey:key];
            
            IMP imp = [self methodForSelector:setter];
            void (*func)(id, SEL, NSObject *) = (void *)imp;
            func(self, setter, obj);
        }
    }];
}

- (NSObject *)preparedObject:(NSObject *)object  forKey:(NSString *)key {
    
    if (![object isKindOfClass:NSDictionary.class] &&
        ![object isKindOfClass:NSArray.class]) {
        return object;
    }
    
    Class customClass = [self customClassForPropertyNamed:key];
    if (!customClass) {
        return object;
    }
    
    if ([object isKindOfClass:NSDictionary.class]) {
        object = [[customClass alloc] initWithJSONDictionary:(NSDictionary *)object];
    }
    else if ([object isKindOfClass:NSArray.class]) {
        NSArray *array = (NSArray *)object;
        NSMutableArray *preparedArray = [NSMutableArray new];
        for (NSDictionary *dictionary in array) {
            VKJSONObject *object = [[customClass alloc] initWithJSONDictionary:dictionary];
            [preparedArray addObject:object];
        }
        
        object = preparedArray;
    }
    
    return object;
}

- (Class)customClassForPropertyNamed:(NSString *)propertyName {
    return nil;
}

@end

@implementation VKFeed

- (Class)customClassForPropertyNamed:(NSString *)propertyName {
    if ([propertyName isEqualToString:pnfs(items)]) {
        return VKFeedItem.class;
    }
    
    if ([propertyName isEqualToString:pnfs(groups)]) {
        return VKGroupInfo.class;
    }
    
    if ([propertyName isEqualToString:pnfs(profiles)]) {
        return VKUserInfo.class;
    }
    
    return [super customClassForPropertyNamed:propertyName];
}

@end

@implementation VKFeedItem

- (Class)customClassForPropertyNamed:(NSString *)propertyName {
    if ([propertyName isEqualToString:pnfs(comments)]) {
        return VKCommentsInfo.class;
    }
    
    if ([propertyName isEqualToString:pnfs(likes)]) {
        return VKLikesInfo.class;
    }
    
    if ([propertyName isEqualToString:pnfs(reposts)]) {
        return VKRepostsInfo.class;
    }
    
    if ([propertyName isEqualToString:pnfs(attachments)]) {
        return VKAttachment.class;
    }
    
    if ([propertyName isEqualToString:pnfs(views)]) {
        return VKViewsInfo.class;
    }
    
    return [super customClassForPropertyNamed:propertyName];
}

@end

@implementation VKCommentsInfo
@end

@implementation VKLikesInfo
@end

@implementation VKRepostsInfo
@end

@implementation VKViewsInfo
@end

@implementation VKAttachment

- (Class)customClassForPropertyNamed:(NSString *)propertyName {
    if ([propertyName isEqualToString:pnfs(photo)]) {
        return VKPhoto.class;
    }
    
    return [super customClassForPropertyNamed:propertyName];
}

@end

@implementation VKPhoto

- (Class)customClassForPropertyNamed:(NSString *)propertyName {
    if ([propertyName isEqualToString:pnfs(sizes)]) {
        return VKPhotoSize.class;
    }
    
    return [super customClassForPropertyNamed:propertyName];
}

@end

@implementation VKPhotoSize
@end

@implementation VKGroupInfo
@end

@implementation VKUserInfo
@end

@implementation VKApiError
- (Class)customClassForPropertyNamed:(NSString *)propertyName {
    if ([propertyName isEqualToString:pnfs(request_params)]) {
        return VKKeyValuePair.class;
    }
    
    return [super customClassForPropertyNamed:propertyName];
}
@end

@implementation VKKeyValuePair
@end
