import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Base contract for all use cases.
///
/// [Type]   — the success value returned inside [Either].
/// [Params] — input parameters; use [NoParams] when none are needed.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Substitute for [Params] when a use case requires no input.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}

/// Single integer identifier — used by "get by id" use cases.
class IdParam extends Equatable {
  final int id;
  const IdParam(this.id);

  @override
  List<Object?> get props => [id];
}

/// List of integer identifiers — used by "get multiple" use cases.
class IdsParam extends Equatable {
  final List<int> ids;
  const IdsParam(this.ids);

  @override
  List<Object?> get props => [ids];
}
