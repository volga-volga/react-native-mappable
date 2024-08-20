#import <React/RCTConvert.h>
#import <Foundation/Foundation.h>
@import MappableMobile;

@interface RCTConvert(Mappable)

@end

@implementation RCTConvert(Mappable)

+ (MMKPoint*)MMKPoint:(id)json {
    json = [self NSDictionary:json];
    MMKPoint *target = [MMKPoint pointWithLatitude:[self double:json[@"lat"]] longitude:[self double:json[@"lon"]]];

    return target;
}

+ (MMKScreenPoint*)MMKScreenPoint:(id)json {
    json = [self NSDictionary:json];
    MMKScreenPoint *target = [MMKScreenPoint screenPointWithX:[self float:json[@"x"]] y:[self float:json[@"y"]]];

    return target;
}

+ (NSArray*)Vehicles:(id)json {
    return [self NSArray:json];
}

+ (NSMutableArray<MMKPoint*>*)Points:(id)json {
    NSArray* parsedArray = [self NSArray:json];
    NSMutableArray* result = [[NSMutableArray alloc] init];

    for (NSDictionary* jsonMarker in parsedArray) {
        double lat = [[jsonMarker valueForKey:@"lat"] doubleValue];
        double lon = [[jsonMarker valueForKey:@"lon"] doubleValue];
        MMKPoint *point = [MMKPoint pointWithLatitude:lat longitude:lon];
        [result addObject:point];
    }

    return result;
}

+ (NSMutableArray<MMKScreenPoint*>*)ScreenPoints:(id)json {
    NSArray* parsedArray = [self NSArray:json];
    NSMutableArray* result = [[NSMutableArray alloc] init];

    for (NSDictionary* jsonMarker in parsedArray) {
        float x = [[jsonMarker valueForKey:@"x"] floatValue];
        float y = [[jsonMarker valueForKey:@"y"] floatValue];
        MMKScreenPoint *point = [MMKScreenPoint screenPointWithX:x y:y];
        [result addObject:point];
    }

    return result;
}

+ (float)Zoom:(id)json {
    json = [self NSDictionary:json];
    return [self float:json[@"zoom"]];
}

+ (float)Azimuth:(id)json {
    json = [self NSDictionary:json];
    return [self float:json[@"azimuth"]];
}

+ (float)Tilt:(id)json {
    json = [self NSDictionary:json];
    return [self float:json[@"tilt"]];
}

@end
