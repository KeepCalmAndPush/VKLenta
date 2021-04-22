//
//  VKEntities.h
//  BigBookTest
//
//  Created by Андрей Соловьев on 10/11/2018.
//  Copyright © 2018 andrey. All rights reserved.
//

#import <Foundation/Foundation.h>


@class VKFeedItem;
@class VKCommentsInfo;
@class VKLikesInfo;
@class VKRepostsInfo;
@class VKViewsInfo;
@class VKGroupInfo;
@class VKUserInfo;
@class VKAttachment;
@class VKPhoto;
@class VKPhotoSize;
@class VKApiError;
@class VKKeyValuePair;

@protocol VKJSONInitable <NSObject>
- (instancetype)initWithJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary;
/// Property class, or class of elements in array, if the property is array
- (Class)customClassForPropertyNamed:(NSString *)propertyName;
@end

@interface VKJSONObject : NSObject<VKJSONInitable>
@end

@interface VKFeed : VKJSONObject
@property (nonatomic) NSArray<VKFeedItem *> *items;
@property (nonatomic) NSArray<VKGroupInfo *> *groups;
@property (nonatomic) NSArray<VKUserInfo *> *profiles;
@property (nonatomic, copy) NSString *next_from;
@end

@interface VKFeedItem : VKJSONObject

@property (nonatomic) VKCommentsInfo *comments;
@property (nonatomic) VKLikesInfo *likes;
@property (nonatomic) VKRepostsInfo *reposts;
@property (nonatomic) VKViewsInfo *views;

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *post_type;
@property (nonatomic, copy) NSNumber *post_id;
@property (nonatomic, copy) NSNumber *date;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSNumber *source_id;
@property (nonatomic) NSArray<VKAttachment *> *attachments;

@end

@interface VKCommentsInfo : VKJSONObject
@property (nonatomic, copy) NSNumber *count;
@property (nonatomic, copy) NSNumber *can_post;
@property (nonatomic, copy) NSNumber *groups_can_post;
@end


@interface VKLikesInfo : VKJSONObject
@property (nonatomic, copy) NSNumber *can_like;
@property (nonatomic, copy) NSNumber *can_publish;
@property (nonatomic, copy) NSNumber *count;
@property (nonatomic, copy) NSNumber *user_likes;
@end

@interface VKRepostsInfo : VKJSONObject
@property (nonatomic, copy) NSNumber *count;
@property (nonatomic, copy) NSNumber *user_reposted;
@end

@interface VKViewsInfo : VKJSONObject
@property (nonatomic, copy) NSNumber *count;
@end

@interface VKAttachment : VKJSONObject
// For the purposes of this app, locked to 'photo'
@property (nonatomic, copy) NSString *type;
// For the purposes of this app, locked to VKPhoto
@property (nonatomic) VKPhoto *photo;
@end

@interface VKPhoto : VKJSONObject
@property (nonatomic, copy) NSNumber *album_id;
@property (nonatomic, copy) NSNumber *post_id;
@property (nonatomic, copy) NSNumber *id;
@property (nonatomic, copy) NSNumber *date;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSNumber *user_id;
@property (nonatomic) NSArray<VKPhotoSize *> *sizes;
@end

@interface VKPhotoSize : VKJSONObject
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSNumber *width;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSNumber *height;
@end


@interface VKGroupInfo : VKJSONObject
@property (nonatomic, copy) NSNumber *id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *photo_100;
@property (nonatomic, copy) NSString *photo_50;
@property (nonatomic, copy) NSString *photo_200;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *screen_name;
@property (nonatomic, copy) NSNumber *is_closed;
@end

@interface VKUserInfo : VKJSONObject
@property (nonatomic, copy) NSNumber *online;
@property (nonatomic, copy) NSString *first_name;
@property (nonatomic, copy) NSNumber *id;
@property (nonatomic, copy) NSString *photo_100;
@property (nonatomic, copy) NSString *last_name;
@property (nonatomic, copy) NSString *photo_50;
@property (nonatomic, copy) NSNumber *online_mobile;
@property (nonatomic, copy) NSString *screen_name;
@property (nonatomic, copy) NSNumber *sex;
@property (nonatomic, copy) NSString *online_app;

@end


@interface VKApiError : VKJSONObject
@property (nonatomic, copy) NSNumber *error_code;
@property (nonatomic, copy) NSString *error_msg;
@property (nonatomic) NSArray<VKKeyValuePair *> *request_params;
@end

@interface VKKeyValuePair : VKJSONObject
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *value;
@end
