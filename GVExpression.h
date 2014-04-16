#import <Foundation/Foundation.h>



#pragma mark - protocol GVExpression

@protocol GVExpression <NSObject>
@required

- (BOOL)validateText:(NSString *)text;

@end




#pragma mark - protocol GVFormatter

@protocol GVFormatter <NSObject>
@required

- (NSString *)formattedText:(NSString *)text;

@end



#pragma mark - class GVNumbersRegularExpression

/*!
 @discussion Проверяет текст на наличие цифровых символов и десятичного разделителя, если он необходим.
 @code 
 NSString *str_NO_VALID     = @"15.0d";
 NSString *str_VALID        = @"15.0";
 
 GVNumbersRegularExpression *expression     = [GVNumbersRegularExpression new];
 expression.numberOfDecimalFractions        = 1;
 BOOL isNoValid = [expression validateText:str_NO_VALID];
 BOOL isValid = [expression validateText:str_VALID];
 @endcode
 */

@interface GVNumbersRegularExpression : NSObject <GVExpression>

/*!
 @discussion 
 Игнорирует, если первый символ = '0'
 
 @def YES
 */
@property (nonatomic, assign) BOOL firstSymbolIsZeroAvailable;
/*!
 @discussion
 Количество десятичных чисел после дроби.
 
 @def 0
 */
@property (nonatomic, assign) NSUInteger numberOfDecimalFractions;
/*!
 @discussion
 Разделитель дробной части.
 
 @example '.' или ','
 @def берется из [NSLocale currentLocale]
 */
@property (nonatomic, assign) NSString *decimalSeparator;

@end



#pragma mark - class GVStringsRegularExpression

/*!
 @discussion Проверяет текст на наличие только букв
 @warning    По default игнорирует символы пунктуации.
 @code
 NSString *str_NO_VALID     = @"Vladimir2";
 NSString *str_VALID        = @"Vladimir";
 
 GVStringsRegularExpression *expression     = [GVStringsRegularExpression new];
 BOOL isNoValid = [expression validateText:str_NO_VALID];
 BOOL isValid = [expression validateText:str_VALID];
 @endcode
 */

@interface GVStringsRegularExpression : NSObject <GVExpression>

/*!
 @discussion
 Набор символов для игнорирования
 
 @example   [NSCharacterSet punctuationCharacterSet]
 @def       [NSCharacterSet punctuationCharacterSet]
 */
@property (nonatomic, strong) NSCharacterSet *ignoreSymbols;            //                         def. [NSCharacterSet punctuationCharacterSet]

@end




#pragma mark - class GVEmailRegularExpression

/*!
 @discussion Проверяет text на формат email
 @code
 NSString *str_NO_VALID     = @"example@s";
 NSString *str_VALID        = @"example@mail.com";
 
 GVEmailRegularExpression *expression     = [GVEmailRegularExpression new];
 BOOL isNoValid = [expression validateText:str_NO_VALID];
 BOOL isValid = [expression validateText:str_VALID];
 @endcode
 */

@interface GVEmailRegularExpression : NSObject <GVExpression>

@end




#pragma mark - class GVPhoneFormatter

/*!
 @discussion Проверяет текст на соотвествие формата телефонного номера
 */

@interface GVPhoneFormatter : NSObject <GVExpression, GVFormatter>

/*!
 @discussion
 Формат телефонного номера
 @warning Символ заменяемого текста должен быть %@
 
 @example   +7(%@%@%@)-%@%@%@-%@%@-%@%@
 @def       +%@(%@%@%@)-%@%@%@-%@%@-%@%@
 */
@property (nonatomic, strong) NSString *format;

/*!
 @discussion
 Символ для показа незаполненых символов
 
 @example   @"_"
 @def       nil
 */
@property (nonatomic, assign) NSString *maskSymbol;
/*!
 @discussion
 Отображать ли маску
 
 @def       NO
 */
@property (nonatomic, assign) BOOL displayMaskSymbols;

@end
