import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Base contract for all use cases.
///
/// [Type]   — the success value returned inside [Either].
/// [Params] — input parameters; use [NoParams] when none are needed.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Substitute for [Params] when a use case requires no input.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
