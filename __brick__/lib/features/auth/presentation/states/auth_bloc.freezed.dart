// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent()';
}


}

/// @nodoc
class $AuthEventCopyWith<$Res>  {
$AuthEventCopyWith(AuthEvent _, $Res Function(AuthEvent) __);
}


/// Adds pattern-matching-related methods to [AuthEvent].
extension AuthEventPatterns on AuthEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Started value)?  started,TResult Function( _SignInRequested value)?  signInRequested,TResult Function( _SignOutRequested value)?  signOutRequested,TResult Function( _ContinueAsGuestRequested value)?  continueAsGuestRequested,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _SignInRequested() when signInRequested != null:
return signInRequested(_that);case _SignOutRequested() when signOutRequested != null:
return signOutRequested(_that);case _ContinueAsGuestRequested() when continueAsGuestRequested != null:
return continueAsGuestRequested(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Started value)  started,required TResult Function( _SignInRequested value)  signInRequested,required TResult Function( _SignOutRequested value)  signOutRequested,required TResult Function( _ContinueAsGuestRequested value)  continueAsGuestRequested,}){
final _that = this;
switch (_that) {
case _Started():
return started(_that);case _SignInRequested():
return signInRequested(_that);case _SignOutRequested():
return signOutRequested(_that);case _ContinueAsGuestRequested():
return continueAsGuestRequested(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Started value)?  started,TResult? Function( _SignInRequested value)?  signInRequested,TResult? Function( _SignOutRequested value)?  signOutRequested,TResult? Function( _ContinueAsGuestRequested value)?  continueAsGuestRequested,}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _SignInRequested() when signInRequested != null:
return signInRequested(_that);case _SignOutRequested() when signOutRequested != null:
return signOutRequested(_that);case _ContinueAsGuestRequested() when continueAsGuestRequested != null:
return continueAsGuestRequested(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function( String email,  String password)?  signInRequested,TResult Function()?  signOutRequested,TResult Function()?  continueAsGuestRequested,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _SignInRequested() when signInRequested != null:
return signInRequested(_that.email,_that.password);case _SignOutRequested() when signOutRequested != null:
return signOutRequested();case _ContinueAsGuestRequested() when continueAsGuestRequested != null:
return continueAsGuestRequested();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function( String email,  String password)  signInRequested,required TResult Function()  signOutRequested,required TResult Function()  continueAsGuestRequested,}) {final _that = this;
switch (_that) {
case _Started():
return started();case _SignInRequested():
return signInRequested(_that.email,_that.password);case _SignOutRequested():
return signOutRequested();case _ContinueAsGuestRequested():
return continueAsGuestRequested();case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function( String email,  String password)?  signInRequested,TResult? Function()?  signOutRequested,TResult? Function()?  continueAsGuestRequested,}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _SignInRequested() when signInRequested != null:
return signInRequested(_that.email,_that.password);case _SignOutRequested() when signOutRequested != null:
return signOutRequested();case _ContinueAsGuestRequested() when continueAsGuestRequested != null:
return continueAsGuestRequested();case _:
  return null;

}
}

}

/// @nodoc


class _Started implements AuthEvent {
  const _Started();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Started);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.started()';
}


}




/// @nodoc


class _SignInRequested implements AuthEvent {
  const _SignInRequested({this.email = '', this.password = ''});
  

@JsonKey() final  String email;
@JsonKey() final  String password;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignInRequestedCopyWith<_SignInRequested> get copyWith => __$SignInRequestedCopyWithImpl<_SignInRequested>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignInRequested&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}


@override
int get hashCode => Object.hash(runtimeType,email,password);

@override
String toString() {
  return 'AuthEvent.signInRequested(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class _$SignInRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory _$SignInRequestedCopyWith(_SignInRequested value, $Res Function(_SignInRequested) _then) = __$SignInRequestedCopyWithImpl;
@useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class __$SignInRequestedCopyWithImpl<$Res>
    implements _$SignInRequestedCopyWith<$Res> {
  __$SignInRequestedCopyWithImpl(this._self, this._then);

  final _SignInRequested _self;
  final $Res Function(_SignInRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,}) {
  return _then(_SignInRequested(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _SignOutRequested implements AuthEvent {
  const _SignOutRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignOutRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.signOutRequested()';
}


}




/// @nodoc


class _ContinueAsGuestRequested implements AuthEvent {
  const _ContinueAsGuestRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContinueAsGuestRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.continueAsGuestRequested()';
}


}




/// @nodoc
mixin _$AuthState {

/// A `BlocStatus` per operation, as `features_overview.md` requires — one
/// shared status would make a sign-out spinner appear on the sign-in button.
 BlocStatus<UserEntity> get signInStatus; BlocStatus<void> get signOutStatus;/// True when the user dismissed a platform sign-in dialog.
///
/// Kept apart from a failure on purpose: cancelling is a choice, not an
/// error, and must not be shown in red.
 bool get wasCancelled;
/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthStateCopyWith<AuthState> get copyWith => _$AuthStateCopyWithImpl<AuthState>(this as AuthState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState&&(identical(other.signInStatus, signInStatus) || other.signInStatus == signInStatus)&&(identical(other.signOutStatus, signOutStatus) || other.signOutStatus == signOutStatus)&&(identical(other.wasCancelled, wasCancelled) || other.wasCancelled == wasCancelled));
}


@override
int get hashCode => Object.hash(runtimeType,signInStatus,signOutStatus,wasCancelled);

@override
String toString() {
  return 'AuthState(signInStatus: $signInStatus, signOutStatus: $signOutStatus, wasCancelled: $wasCancelled)';
}


}

/// @nodoc
abstract mixin class $AuthStateCopyWith<$Res>  {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) _then) = _$AuthStateCopyWithImpl;
@useResult
$Res call({
 BlocStatus<UserEntity> signInStatus, BlocStatus<void> signOutStatus, bool wasCancelled
});


$BlocStatusCopyWith<UserEntity, $Res> get signInStatus;$BlocStatusCopyWith<void, $Res> get signOutStatus;

}
/// @nodoc
class _$AuthStateCopyWithImpl<$Res>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._self, this._then);

  final AuthState _self;
  final $Res Function(AuthState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? signInStatus = null,Object? signOutStatus = null,Object? wasCancelled = null,}) {
  return _then(_self.copyWith(
signInStatus: null == signInStatus ? _self.signInStatus : signInStatus // ignore: cast_nullable_to_non_nullable
as BlocStatus<UserEntity>,signOutStatus: null == signOutStatus ? _self.signOutStatus : signOutStatus // ignore: cast_nullable_to_non_nullable
as BlocStatus<void>,wasCancelled: null == wasCancelled ? _self.wasCancelled : wasCancelled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlocStatusCopyWith<UserEntity, $Res> get signInStatus {
  
  return $BlocStatusCopyWith<UserEntity, $Res>(_self.signInStatus, (value) {
    return _then(_self.copyWith(signInStatus: value));
  });
}/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlocStatusCopyWith<void, $Res> get signOutStatus {
  
  return $BlocStatusCopyWith<void, $Res>(_self.signOutStatus, (value) {
    return _then(_self.copyWith(signOutStatus: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthState].
extension AuthStatePatterns on AuthState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthState value)  $default,){
final _that = this;
switch (_that) {
case _AuthState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthState value)?  $default,){
final _that = this;
switch (_that) {
case _AuthState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BlocStatus<UserEntity> signInStatus,  BlocStatus<void> signOutStatus,  bool wasCancelled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthState() when $default != null:
return $default(_that.signInStatus,_that.signOutStatus,_that.wasCancelled);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BlocStatus<UserEntity> signInStatus,  BlocStatus<void> signOutStatus,  bool wasCancelled)  $default,) {final _that = this;
switch (_that) {
case _AuthState():
return $default(_that.signInStatus,_that.signOutStatus,_that.wasCancelled);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BlocStatus<UserEntity> signInStatus,  BlocStatus<void> signOutStatus,  bool wasCancelled)?  $default,) {final _that = this;
switch (_that) {
case _AuthState() when $default != null:
return $default(_that.signInStatus,_that.signOutStatus,_that.wasCancelled);case _:
  return null;

}
}

}

/// @nodoc


class _AuthState implements AuthState {
  const _AuthState({this.signInStatus = const BlocStatus<UserEntity>.initial(), this.signOutStatus = const BlocStatus<void>.initial(), this.wasCancelled = false});
  

/// A `BlocStatus` per operation, as `features_overview.md` requires — one
/// shared status would make a sign-out spinner appear on the sign-in button.
@override@JsonKey() final  BlocStatus<UserEntity> signInStatus;
@override@JsonKey() final  BlocStatus<void> signOutStatus;
/// True when the user dismissed a platform sign-in dialog.
///
/// Kept apart from a failure on purpose: cancelling is a choice, not an
/// error, and must not be shown in red.
@override@JsonKey() final  bool wasCancelled;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthStateCopyWith<_AuthState> get copyWith => __$AuthStateCopyWithImpl<_AuthState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthState&&(identical(other.signInStatus, signInStatus) || other.signInStatus == signInStatus)&&(identical(other.signOutStatus, signOutStatus) || other.signOutStatus == signOutStatus)&&(identical(other.wasCancelled, wasCancelled) || other.wasCancelled == wasCancelled));
}


@override
int get hashCode => Object.hash(runtimeType,signInStatus,signOutStatus,wasCancelled);

@override
String toString() {
  return 'AuthState(signInStatus: $signInStatus, signOutStatus: $signOutStatus, wasCancelled: $wasCancelled)';
}


}

/// @nodoc
abstract mixin class _$AuthStateCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$AuthStateCopyWith(_AuthState value, $Res Function(_AuthState) _then) = __$AuthStateCopyWithImpl;
@override @useResult
$Res call({
 BlocStatus<UserEntity> signInStatus, BlocStatus<void> signOutStatus, bool wasCancelled
});


@override $BlocStatusCopyWith<UserEntity, $Res> get signInStatus;@override $BlocStatusCopyWith<void, $Res> get signOutStatus;

}
/// @nodoc
class __$AuthStateCopyWithImpl<$Res>
    implements _$AuthStateCopyWith<$Res> {
  __$AuthStateCopyWithImpl(this._self, this._then);

  final _AuthState _self;
  final $Res Function(_AuthState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? signInStatus = null,Object? signOutStatus = null,Object? wasCancelled = null,}) {
  return _then(_AuthState(
signInStatus: null == signInStatus ? _self.signInStatus : signInStatus // ignore: cast_nullable_to_non_nullable
as BlocStatus<UserEntity>,signOutStatus: null == signOutStatus ? _self.signOutStatus : signOutStatus // ignore: cast_nullable_to_non_nullable
as BlocStatus<void>,wasCancelled: null == wasCancelled ? _self.wasCancelled : wasCancelled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlocStatusCopyWith<UserEntity, $Res> get signInStatus {
  
  return $BlocStatusCopyWith<UserEntity, $Res>(_self.signInStatus, (value) {
    return _then(_self.copyWith(signInStatus: value));
  });
}/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlocStatusCopyWith<void, $Res> get signOutStatus {
  
  return $BlocStatusCopyWith<void, $Res>(_self.signOutStatus, (value) {
    return _then(_self.copyWith(signOutStatus: value));
  });
}
}

// dart format on
