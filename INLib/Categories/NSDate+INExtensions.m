// NSDate+INExtensions.m
//
// Copyright (c) 2014 Sven Korset
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "NSDate+INExtensions.h"


IDateInformation IDateInformationMake(NSInteger year, NSInteger month, NSInteger day, NSInteger hour, NSInteger minute, NSInteger second) {
    IDateInformation info;
    info.year = year;
    info.month = month;
    info.day = day;
    info.hour = hour;
    info.minute = minute;
    info.second = second;
    return info;
}


// private declarations
@interface NSDate (INExtension)

+ (NSCalendar *)cachedGregorianCalendar;

@end


// use a static gregorian calendar for performance purposes because creating it at runtime is time expensive
static NSCalendar *__defaultCachedGregorianCalendar = nil;
// the last used weekday number as the first weekday in a week for the weekday calculating method
static NSUInteger __lastUsedFirstWeekday = 1; // sunday is apple's default for the U.S.
// the static date formatter for the weekday calculating method
static NSDateFormatter *__dateFormatterForWeekday = nil;
// dict with cached NSDateFormatter objects, keys are the formatter strings
static NSMutableDictionary *__cachedDateFormatters;


@implementation NSDate (IExtensions)


#pragma mark - private methods

+ (NSCalendar *)cachedGregorianCalendar {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // create the calendar
        __defaultCachedGregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [__defaultCachedGregorianCalendar setMinimumDaysInFirstWeek:4]; // iOS 5 workaround
    });
    return __defaultCachedGregorianCalendar;
}


#pragma mark - public methods

+ (NSDateFormatter *)cachedDateFormatterForFormat:(NSString *)format {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __cachedDateFormatters = [[NSMutableDictionary alloc] initWithCapacity:10];

        // add observer for clearing the cache
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:[UIApplication sharedApplication] queue:nil usingBlock:^(NSNotification *notification){
            @synchronized(__cachedDateFormatters) {
                [__cachedDateFormatters removeAllObjects];
            }
        }];
    });
    
    NSDateFormatter *dateFormatter = nil;
    @synchronized (__cachedDateFormatters) {
        dateFormatter = [__cachedDateFormatters objectForKey:format];
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:format];
            [__cachedDateFormatters setObject:dateFormatter forKey:format];
        }
    }
    return dateFormatter;
}

- (BOOL)isToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setMinimumDaysInFirstWeek:4]; // iOS 5 workaround

    NSUInteger components = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *comp1 = [calendar components:components fromDate:self];
    NSDateComponents *comp2 = [calendar components:components fromDate:[NSDate date]];

    // isToday if day, month and year of NSDate are equal
    return [comp1 day] == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year] == [comp2 year];
}

- (BOOL)isSameDay:(NSDate *)otherDate {
	NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setMinimumDaysInFirstWeek:4]; // iOS 5 workaround
    
    NSUInteger components = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
	NSDateComponents *comp1 = [calendar components:components fromDate:self];
	NSDateComponents *comp2 = [calendar components:components fromDate:otherDate];
    
    return [comp1 day] == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year] == [comp2 year];
} 


- (IDateInformation)dateInformation {
	IDateInformation info;
	
    NSUInteger components = NSMonthCalendarUnit | NSMinuteCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSSecondCalendarUnit;
    NSCalendar *gregorian = [NSDate cachedGregorianCalendar];
    @synchronized(gregorian) {
        NSDateComponents *comp = [gregorian components:components fromDate:self];
    
        info.year = [comp year];
        info.month = [comp month];
        info.day = [comp day];
        info.weekday = [comp weekday];
        info.hour = [comp hour];
        info.minute = [comp minute];
        info.second = [comp second];
    }
    
	return info;
}

- (IDateInformation)dateInformationWithTimeZone:(NSTimeZone *)timeZone {
	IDateInformation info;
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setMinimumDaysInFirstWeek:4]; // iOS 5 workaround
	[gregorian setTimeZone:timeZone];
    NSUInteger components = NSMonthCalendarUnit | NSMinuteCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSSecondCalendarUnit;
	NSDateComponents *comp = [gregorian components:components fromDate:self];
    
	info.year = [comp year];
	info.month = [comp month];
	info.day = [comp day];
	info.weekday = [comp weekday];
	info.hour = [comp hour];
	info.minute = [comp minute];
	info.second = [comp second];
	
	return info;
}

+ (NSDate *)dateWithDateInformation:(IDateInformation)dateInfo timeZone:(NSTimeZone*)timeZone {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:dateInfo.year];
    [comps setMonth:dateInfo.month];
    [comps setDay:dateInfo.day];
    [comps setHour:dateInfo.hour];
    [comps setMinute:dateInfo.minute];
    [comps setSecond:dateInfo.second];
    [comps setTimeZone:timeZone];

    NSCalendar *gregorian = [NSDate cachedGregorianCalendar];
    NSDate *date;
    @synchronized(gregorian) {
        date = [gregorian dateFromComponents:comps];
    }
    
    return date;
}

+ (NSDate *)dateWithDateInformation:(IDateInformation)dateInfo {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:dateInfo.year];
    [comps setMonth:dateInfo.month];
    [comps setDay:dateInfo.day];
    [comps setHour:dateInfo.hour];
    [comps setMinute:dateInfo.minute];
    [comps setSecond:dateInfo.second];
	
    NSCalendar *gregorian = [NSDate cachedGregorianCalendar];
    NSDate *date;
    @synchronized(gregorian) {
        date = [gregorian dateFromComponents:comps];
    }
    
    return date;
}

- (NSDate *)dateWithFirstOfMonth {
	IDateInformation info = [self dateInformation];
	info.day = 1;
	info.minute = 0;
	info.second = 0;
	info.hour = 0;
	return [NSDate dateWithDateInformation:info];
}

- (NSDate *)dateWithLastOfMonth {
	IDateInformation info = [self dateInformation];
    NSDate *temp;
    for (int i = 0; i < 4; i++) {
        info.day = 31 - i;
        info.minute = 0;
        info.second = 0;
        info.hour = 0;
        temp = [NSDate dateWithDateInformation:info];
        if (temp.dayNumberOfMonth == 31 - i) {
            break;
        }
    }
    return temp;
}

- (NSDate *)dateWithNextMonth {
	IDateInformation info = [self dateInformation];
	info.month++;
	if (info.month > 12) {
		info.month = 1;
		info.year++;
	}
    NSInteger month = info.month;
    NSDate *date = [NSDate dateWithDateInformation:info];
    if (date.monthNumber != month) {
        return [[[date dateWithFirstOfMonth] dateWithPrevMonth] dateWithLastOfMonth];
    }
    return date;
}

- (NSDate *)dateWithPrevMonth {
	IDateInformation info = [self dateInformation];
	info.month--;
	if (info.month < 1) {
		info.month = 12;
		info.year--;
	}
    NSInteger month = info.month;
    NSDate *date = [NSDate dateWithDateInformation:info];
    if (date.monthNumber != month) {
        return [[[date dateWithFirstOfMonth] dateWithPrevMonth] dateWithLastOfMonth];
    }
    return date;
}

- (NSDate *)dateWithWeekstart:(NSInteger)daynumber {
    IDateInformation dateInfo = [self dateInformation];
    NSInteger daysToSub = (dateInfo.weekday - daynumber + 7) % 7;
    NSDate *date = [self dateWithDaysAdded:-daysToSub];
    return date;
}


// see http://unicode.org/reports/tr35/tr35-10.html#Date_Format_Patterns

- (NSInteger)yearNumber {
	NSDateFormatter *dateFormatter = [NSDate cachedDateFormatterForFormat:@"yyyy"];
    NSString *string = nil;
    @synchronized(dateFormatter) {
        string = [dateFormatter stringFromDate:self];
    }
	return [string intValue];
}

- (NSInteger)monthNumber {
	NSDateFormatter *dateFormatter = [NSDate cachedDateFormatterForFormat:@"MM"];
    NSString *string = nil;
    @synchronized(dateFormatter) {
        string = [dateFormatter stringFromDate:self];
    }
	return [string intValue];
}

- (NSInteger)quarterNumber {
	NSDateFormatter *dateFormatter = [NSDate cachedDateFormatterForFormat:@"q"];
    NSString *string = nil;
    @synchronized(dateFormatter) {
        string = [dateFormatter stringFromDate:self];
    }
	return [string intValue];
}

+ (void)createDateFormatterForWeekdateIfNeeded {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // create the date formatter
        __dateFormatterForWeekday = [[NSDateFormatter alloc] init];
        [__dateFormatterForWeekday setDateFormat:@"ww"];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [gregorian setMinimumDaysInFirstWeek:4]; // iOS 5 workaround
        [gregorian setLocale:[NSLocale currentLocale]]; // use to determine first weekday
        __lastUsedFirstWeekday = gregorian.firstWeekday;
        __dateFormatterForWeekday.calendar = gregorian;
    });
}

- (NSInteger)weekNumberOfYearBeginningWithFirstWeekday:(NSUInteger)firstWeekday {
    // use static date formatter for performance purposes
    [NSDate createDateFormatterForWeekdateIfNeeded];
    
    // change weekday only if necessary
    if (__lastUsedFirstWeekday != firstWeekday) {
        @synchronized(__dateFormatterForWeekday) {
            NSCalendar *gregorian = __dateFormatterForWeekday.calendar;
            [gregorian setFirstWeekday:firstWeekday];
            __dateFormatterForWeekday.calendar = gregorian; // needs to be assigned back
            __lastUsedFirstWeekday = firstWeekday;
        }
    }
    
    // get the value
	NSString *string = [__dateFormatterForWeekday stringFromDate:self];
	return [string intValue];
}

- (NSInteger)weekNumberOfYear {
    // use static date formatter for performance purposes
    [NSDate createDateFormatterForWeekdateIfNeeded];
    
    // get the value
	NSString *string = [__dateFormatterForWeekday stringFromDate:self];
	return [string intValue];
}

+ (NSUInteger)firstWeekdayUsedForWeekNumberDateFormatter {
    // use static date formatter for performance purposes
    [NSDate createDateFormatterForWeekdateIfNeeded];
    
    return __dateFormatterForWeekday.calendar.firstWeekday;
}

- (NSInteger)weekNumberOfMonth {
	NSDateFormatter *dateFormatter = [NSDate cachedDateFormatterForFormat:@"W"];
    NSString *string = nil;
    @synchronized(dateFormatter) {
        string = [dateFormatter stringFromDate:self];
    }
	return [string intValue];
}

- (NSInteger)dayNumberOfMonth {
	NSDateFormatter *dateFormatter = [NSDate cachedDateFormatterForFormat:@"dd"];
    NSString *string = nil;
    @synchronized(dateFormatter) {
        string = [dateFormatter stringFromDate:self];
    }
	return [string intValue];
}

- (NSInteger)dayNumberOfYear {
	NSDateFormatter *dateFormatter = [NSDate cachedDateFormatterForFormat:@"DDD"];
    NSString *string = nil;
    @synchronized(dateFormatter) {
        string = [dateFormatter stringFromDate:self];
    }
	return [string intValue];
}

- (NSInteger)dayNumberOfWeekInMonth {
	NSDateFormatter *dateFormatter = [NSDate cachedDateFormatterForFormat:@"F"];
    NSString *string = nil;
    @synchronized(dateFormatter) {
        string = [dateFormatter stringFromDate:self];
    }
	return [string intValue];
}

- (NSInteger)weekdayNumber {
	NSDateFormatter *dateFormatter = [NSDate cachedDateFormatterForFormat:@"e"];
    NSString *string = nil;
    @synchronized(dateFormatter) {
        string = [dateFormatter stringFromDate:self];
    }
	return [string intValue];
}

- (NSInteger)hourNumber {
	NSDateFormatter *dateFormatter = [NSDate cachedDateFormatterForFormat:@"HH"];
    NSString *string = nil;
    @synchronized(dateFormatter) {
        string = [dateFormatter stringFromDate:self];
    }
	return [string intValue];
}

- (NSInteger)minuteNumber {
	NSDateFormatter *dateFormatter = [NSDate cachedDateFormatterForFormat:@"mm"];
    NSString *string = nil;
    @synchronized(dateFormatter) {
        string = [dateFormatter stringFromDate:self];
    }
	return [string intValue];
}

- (NSInteger)secondNumber {
	NSDateFormatter *dateFormatter = [NSDate cachedDateFormatterForFormat:@"ss"];
    NSString *string = nil;
    @synchronized(dateFormatter) {
        string = [dateFormatter stringFromDate:self];
    }
	return [string intValue];
}

- (NSString *)stringWithMonthName {
	NSDateFormatter *dateFormatter = [NSDate cachedDateFormatterForFormat:@"MMMM"];
    NSString *string = nil;
    @synchronized(dateFormatter) {
        string = [dateFormatter stringFromDate:self];
    }
    return string;
}

- (NSString *)stringWithWeekdayName {
	NSDateFormatter *dateFormatter = [NSDate cachedDateFormatterForFormat:@"eeee"];
    NSString *string = nil;
    @synchronized(dateFormatter) {
        string = [dateFormatter stringFromDate:self];
    }
    return string;
}

- (NSString *)stringWithWeekdayNameShort {
	NSDateFormatter *dateFormatter = [NSDate cachedDateFormatterForFormat:@"eee"];
    NSString *string = nil;
    @synchronized(dateFormatter) {
        string = [dateFormatter stringFromDate:self];
    }
    return string;
}

- (NSInteger)monthsBetweenDate:(NSDate *)otherDate {
	if (otherDate == nil) return 0;
	
	NSDate *firstDate = self;
	NSDate *lastDate = otherDate;
	if ([firstDate compare:lastDate] == NSOrderedDescending) {
		firstDate = otherDate;
		lastDate = self;
	}
	
	NSInteger startYear = [firstDate yearNumber];
	NSInteger endYear = [lastDate yearNumber];
	NSInteger startMonth = [firstDate monthNumber];
	NSInteger endMonth = [lastDate monthNumber];
	NSInteger totalMonths = 0;
    
	if (endYear - startYear > 1) {
		totalMonths += (endYear - startYear - 1) * 12;
	}
	if (endMonth > startMonth) {
		totalMonths += endMonth - startMonth + 1;
		if (endYear > startYear) {
			totalMonths += 12;
		}
	} else if (endMonth < startMonth) {
		totalMonths += 12 - (startMonth - endMonth - 1);
	} else {
		if (endYear > startYear) {
			totalMonths += 12;
		}
	}
    
	return totalMonths;
}

- (NSInteger)daysBetweenDate:(NSDate *)otherDate {
    NSDateComponents *comps;
    NSCalendar *gregorian = [NSDate cachedGregorianCalendar];
    @synchronized(gregorian) {
        comps = [gregorian components:NSDayCalendarUnit fromDate:self toDate:otherDate options:0];
    }
    
    return [comps day];
}

+ (instancetype)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    NSDateFormatter *dateFormatter = [NSDate cachedDateFormatterForFormat:@"yyyy-MM-dd"];
    NSDate *date = nil;
    @synchronized(dateFormatter) {
        NSString *string = [[NSString alloc] initWithFormat:@"%ld-%02ld-%02ld", (long)year, (long)month, (long)day];
        date = [dateFormatter dateFromString:string];
    }
	return date;
}

+ (instancetype)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second {
    NSDateFormatter *dateFormatter = [NSDate cachedDateFormatterForFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = nil;
    @synchronized(dateFormatter) {
        NSString *string = [[NSString alloc] initWithFormat:@"%ld-%02ld-%02ld %02ld:%02ld:%02ld", (long)year, (long)month, (long)day, (long)hour, (long)minute, (long)second];
        date = [dateFormatter dateFromString:string];
    }
	return date;
}

- (instancetype)dateWithYearReplaced:(NSInteger)year {
    NSDateFormatter *dateFormatter = [NSDate cachedDateFormatterForFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = nil;
    @synchronized(dateFormatter) {
        NSString *string = [dateFormatter stringFromDate:self];
        NSString *yearString = [[NSString alloc] initWithFormat:@"%ld", (long)year];
        string = [string stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:yearString];
        date = [dateFormatter dateFromString:string];
    }
    return date;
}

- (instancetype)dateWithSecondsReplaced:(NSInteger)seconds {
    NSDateFormatter *dateFormatter = [NSDate cachedDateFormatterForFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = nil;
    @synchronized(dateFormatter) {
        [dateFormatter setLocale:[NSLocale currentLocale]];
        NSString *string = [dateFormatter stringFromDate:self];
        NSString *secondsString = [[NSString alloc] initWithFormat:@"%.2ld", (long)seconds];
        string = [string stringByReplacingCharactersInRange:NSMakeRange(17, 2) withString:secondsString];
        date = [dateFormatter dateFromString:string];
    }
    return date;
}

- (instancetype)dateWithTimeZeroed {
    NSDateFormatter *dateFormatter = [NSDate cachedDateFormatterForFormat:@"yyyy-MM-dd"];
    NSDate *date = nil;
    @synchronized(dateFormatter) {
        NSString *string = [dateFormatter stringFromDate:self];
        date = [dateFormatter dateFromString:string];
    }
    return date;
}

- (instancetype)dateWithTimeReplaced:(NSDate *)time {
    IDateInformation dateInfo = [self dateInformation];
    IDateInformation timeInfo = [time dateInformation];
    dateInfo.hour = timeInfo.hour;
    dateInfo.minute = timeInfo.minute;
    dateInfo.second = timeInfo.second;
    return [NSDate dateWithDateInformation:dateInfo];
}

- (NSDate *)dateWithDaysAdded:(NSInteger)days {
	NSDateComponents *components = [[NSDateComponents alloc] init];
	[components setDay:days];
	NSDate *newDate;
    NSCalendar *gregorian = [NSDate cachedGregorianCalendar];
    @synchronized(gregorian) {
        newDate = [gregorian dateByAddingComponents:components toDate:self options:0];
    }
	return newDate;
}

- (instancetype)dateWithMonthsAdded:(NSInteger)months {
	NSDateComponents *components = [[NSDateComponents alloc] init];
	[components setMonth:months];
	NSDate *newDate;
    NSCalendar *gregorian = [NSDate cachedGregorianCalendar];
    @synchronized(gregorian) {
        newDate = [gregorian dateByAddingComponents:components toDate:self options:0];
    }
	return newDate;
}

- (instancetype)dateWithYearsAdded:(NSInteger)years {
	NSDateComponents *components = [[NSDateComponents alloc] init];
	[components setYear:years];
	NSDate *newDate;
    NSCalendar *gregorian = [NSDate cachedGregorianCalendar];
    @synchronized(gregorian) {
        newDate = [gregorian dateByAddingComponents:components toDate:self options:0];
    }
	return newDate;
}


- (BOOL)isBeforeDate:(NSDate *)otherDate {
    return [self compare:otherDate] == NSOrderedAscending;
}

- (BOOL)isAfterDate:(NSDate *)otherDate {
    return [self compare:otherDate] == NSOrderedDescending;
}


@end