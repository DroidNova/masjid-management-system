declare module 'class-validator' {
  type ValidationOptions = Record<string, unknown>;

  export function ArrayMinSize(
    min: number,
    validationOptions?: ValidationOptions,
  ): PropertyDecorator;
  export function IsArray(
    validationOptions?: ValidationOptions,
  ): PropertyDecorator;
  export function IsBoolean(
    validationOptions?: ValidationOptions,
  ): PropertyDecorator;
  export function IsEmail(
    options?: Record<string, unknown>,
    validationOptions?: ValidationOptions,
  ): PropertyDecorator;
  export function IsDateString(
    options?: Record<string, unknown>,
    validationOptions?: ValidationOptions,
  ): PropertyDecorator;
  export function IsEnum(
    entity: object,
    validationOptions?: ValidationOptions,
  ): PropertyDecorator;
  export function IsIn(
    values: readonly unknown[],
    validationOptions?: ValidationOptions,
  ): PropertyDecorator;
  export function IsInt(
    validationOptions?: ValidationOptions,
  ): PropertyDecorator;
  export function IsNumber(
    options?: Record<string, unknown>,
    validationOptions?: ValidationOptions,
  ): PropertyDecorator;
  export function IsOptional(
    validationOptions?: ValidationOptions,
  ): PropertyDecorator;
  export function IsString(
    validationOptions?: ValidationOptions,
  ): PropertyDecorator;
  export function IsUUID(
    version?: string | number,
    validationOptions?: ValidationOptions,
  ): PropertyDecorator;
  export function Matches(
    pattern: RegExp,
    validationOptions?: ValidationOptions,
  ): PropertyDecorator;
  export function Max(
    max: number,
    validationOptions?: ValidationOptions,
  ): PropertyDecorator;
  export function MaxLength(
    max: number,
    validationOptions?: ValidationOptions,
  ): PropertyDecorator;
  export function Min(
    min: number,
    validationOptions?: ValidationOptions,
  ): PropertyDecorator;
  export function MinLength(
    min: number,
    validationOptions?: ValidationOptions,
  ): PropertyDecorator;
  export function ValidateNested(
    validationOptions?: ValidationOptions,
  ): PropertyDecorator;
}
