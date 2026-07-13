import {
  ArgumentsHost,
  BadRequestException,
  Catch,
  ConflictException,
  ExceptionFilter,
  ForbiddenException,
  HttpException,
  HttpStatus,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { PinoLogger } from 'nestjs-pino';
import { ApiException } from '../exceptions/api.exception';
import { ERROR_CODES, type ErrorCode } from '../constants/error-codes.constant';
import { getLogUser } from '../utils/log-user.util';
import { getOrCreateRequestId } from '../utils/request-id.util';

@Catch()
@Injectable()
export class HttpExceptionFilter implements ExceptionFilter {
  constructor(private readonly logger: PinoLogger) {
    this.logger.setContext(HttpExceptionFilter.name);
  }

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const request = ctx.getRequest<Request & { id?: string }>();
    const response = ctx.getResponse<Response>();
    const requestId = this.resolveRequestId(request, response);

    if (exception instanceof ApiException) {
      const payload = exception.getResponse() as Record<string, unknown>;
      const status = exception.getStatus();
      const body = { ...payload, requestId };
      this.logException(exception, request, status, body, requestId);
      response.status(status).json(body);
      return;
    }

    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const exceptionResponse = exception.getResponse();
      const normalized = this.normalizeHttpException(
        status,
        exceptionResponse,
        exception,
        requestId,
      );
      this.logException(exception, request, status, normalized, requestId);
      response.status(status).json(normalized);
      return;
    }

    const body = {
      success: false,
      message: 'Something went wrong. Please try again later.',
      errorCode: ERROR_CODES.INTERNAL_SERVER_ERROR,
      requestId,
    };

    this.logException(
      exception,
      request,
      HttpStatus.INTERNAL_SERVER_ERROR,
      body,
      requestId,
    );
    response.status(HttpStatus.INTERNAL_SERVER_ERROR).json(body);
  }

  private normalizeHttpException(
    status: number,
    body: string | object,
    exception: HttpException,
    requestId: string,
  ) {
    const responseBody = typeof body === 'string' ? { message: body } : body;
    const existingMessage = this.extractMessage(
      responseBody,
      exception.message,
    );
    const errors = this.extractErrors(responseBody);
    const existingCode = this.extractErrorCode(responseBody);

    const mappedCode = existingCode ?? this.mapStatusToCode(status, exception);

    return {
      success: false,
      message: existingMessage,
      errorCode: mappedCode,
      requestId,
      ...(errors ? { errors } : {}),
    };
  }

  private resolveRequestId(
    request: Request & { id?: string },
    response: Response,
  ): string {
    const existingId = request.id ?? response.getHeader('x-request-id');
    const requestId =
      typeof existingId === 'string' && existingId.trim()
        ? existingId
        : getOrCreateRequestId(request);

    request.id = requestId;
    response.setHeader('x-request-id', requestId);
    return requestId;
  }

  private logException(
    exception: unknown,
    request: Request,
    statusCode: number,
    body: Record<string, unknown>,
    requestId: string,
  ): void {
    const error = exception instanceof Error ? exception : undefined;
    const logPayload = {
      requestId,
      method: request.method,
      url: request.originalUrl ?? request.url,
      statusCode,
      errorCode: body.errorCode,
      message: body.message,
      ...getLogUser(request),
      ...(statusCode >= 500 && error?.stack ? { stack: error.stack } : {}),
    };

    if (statusCode >= 500) {
      this.logger.error(logPayload, error?.message ?? 'Unhandled request error');
      return;
    }

    if (
      statusCode === HttpStatus.UNAUTHORIZED ||
      statusCode === HttpStatus.FORBIDDEN
    ) {
      this.logger.info(logPayload, 'Request rejected by authorization');
      return;
    }

    this.logger.warn(logPayload, 'Request failed');
  }

  private mapStatusToCode(status: number, exception: HttpException): ErrorCode {
    if (exception instanceof UnauthorizedException)
      return ERROR_CODES.UNAUTHORIZED;
    if (exception instanceof ForbiddenException) return ERROR_CODES.FORBIDDEN;
    if (exception instanceof NotFoundException) return ERROR_CODES.NOT_FOUND;
    if (exception instanceof ConflictException) return ERROR_CODES.CONFLICT;
    if (exception instanceof BadRequestException)
      return ERROR_CODES.BAD_REQUEST;
    if (status >= 500) return ERROR_CODES.INTERNAL_SERVER_ERROR;
    return ERROR_CODES.BAD_REQUEST;
  }

  private extractMessage(body: object, fallback: string): string {
    const message = (body as { message?: unknown }).message;
    if (Array.isArray(message)) return message[0] ?? fallback;
    if (typeof message === 'string') return message;
    return fallback || 'Request failed';
  }

  private extractErrors(
    body: object,
  ): Record<string, unknown> | string[] | undefined {
    const errors = (body as { errors?: unknown }).errors;
    if (errors && (Array.isArray(errors) || typeof errors === 'object')) {
      return errors as Record<string, unknown> | string[];
    }
    return undefined;
  }

  private extractErrorCode(body: object): ErrorCode | undefined {
    const errorCode = (body as { errorCode?: unknown }).errorCode;
    return typeof errorCode === 'string' ? (errorCode as ErrorCode) : undefined;
  }
}
