// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_item_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FeedItemEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedItemEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FeedItemEvent()';
}


}

/// @nodoc
class $FeedItemEventCopyWith<$Res>  {
$FeedItemEventCopyWith(FeedItemEvent _, $Res Function(FeedItemEvent) __);
}


/// Adds pattern-matching-related methods to [FeedItemEvent].
extension FeedItemEventPatterns on FeedItemEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ItemStarted value)?  started,TResult Function( _ItemRetried value)?  retried,TResult Function( _SaveToggled value)?  saveToggled,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemStarted() when started != null:
return started(_that);case _ItemRetried() when retried != null:
return retried(_that);case _SaveToggled() when saveToggled != null:
return saveToggled(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ItemStarted value)  started,required TResult Function( _ItemRetried value)  retried,required TResult Function( _SaveToggled value)  saveToggled,}){
final _that = this;
switch (_that) {
case _ItemStarted():
return started(_that);case _ItemRetried():
return retried(_that);case _SaveToggled():
return saveToggled(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ItemStarted value)?  started,TResult? Function( _ItemRetried value)?  retried,TResult? Function( _SaveToggled value)?  saveToggled,}){
final _that = this;
switch (_that) {
case _ItemStarted() when started != null:
return started(_that);case _ItemRetried() when retried != null:
return retried(_that);case _SaveToggled() when saveToggled != null:
return saveToggled(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id)?  started,TResult Function()?  retried,TResult Function()?  saveToggled,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemStarted() when started != null:
return started(_that.id);case _ItemRetried() when retried != null:
return retried();case _SaveToggled() when saveToggled != null:
return saveToggled();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id)  started,required TResult Function()  retried,required TResult Function()  saveToggled,}) {final _that = this;
switch (_that) {
case _ItemStarted():
return started(_that.id);case _ItemRetried():
return retried();case _SaveToggled():
return saveToggled();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id)?  started,TResult? Function()?  retried,TResult? Function()?  saveToggled,}) {final _that = this;
switch (_that) {
case _ItemStarted() when started != null:
return started(_that.id);case _ItemRetried() when retried != null:
return retried();case _SaveToggled() when saveToggled != null:
return saveToggled();case _:
  return null;

}
}

}

/// @nodoc


class _ItemStarted implements FeedItemEvent {
  const _ItemStarted(this.id);
  

 final  String id;

/// Create a copy of FeedItemEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemStartedCopyWith<_ItemStarted> get copyWith => __$ItemStartedCopyWithImpl<_ItemStarted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemStarted&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'FeedItemEvent.started(id: $id)';
}


}

/// @nodoc
abstract mixin class _$ItemStartedCopyWith<$Res> implements $FeedItemEventCopyWith<$Res> {
  factory _$ItemStartedCopyWith(_ItemStarted value, $Res Function(_ItemStarted) _then) = __$ItemStartedCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class __$ItemStartedCopyWithImpl<$Res>
    implements _$ItemStartedCopyWith<$Res> {
  __$ItemStartedCopyWithImpl(this._self, this._then);

  final _ItemStarted _self;
  final $Res Function(_ItemStarted) _then;

/// Create a copy of FeedItemEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_ItemStarted(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _ItemRetried implements FeedItemEvent {
  const _ItemRetried();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemRetried);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FeedItemEvent.retried()';
}


}




/// @nodoc


class _SaveToggled implements FeedItemEvent {
  const _SaveToggled();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaveToggled);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FeedItemEvent.saveToggled()';
}


}




/// @nodoc
mixin _$FeedItemState {

 String get id; BlocStatus<FeedItemEntity> get detailState;/// «More like this»: the same category, this item left out.
 BlocStatus<List<FeedItemEntity>> get relatedState; bool get isSaved;/// Bumped on every save toggle, so the page can react to the SAME value
/// twice (save, undo, save).
 int get saveToggles;
/// Create a copy of FeedItemState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedItemStateCopyWith<FeedItemState> get copyWith => _$FeedItemStateCopyWithImpl<FeedItemState>(this as FeedItemState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedItemState&&(identical(other.id, id) || other.id == id)&&(identical(other.detailState, detailState) || other.detailState == detailState)&&(identical(other.relatedState, relatedState) || other.relatedState == relatedState)&&(identical(other.isSaved, isSaved) || other.isSaved == isSaved)&&(identical(other.saveToggles, saveToggles) || other.saveToggles == saveToggles));
}


@override
int get hashCode => Object.hash(runtimeType,id,detailState,relatedState,isSaved,saveToggles);

@override
String toString() {
  return 'FeedItemState(id: $id, detailState: $detailState, relatedState: $relatedState, isSaved: $isSaved, saveToggles: $saveToggles)';
}


}

/// @nodoc
abstract mixin class $FeedItemStateCopyWith<$Res>  {
  factory $FeedItemStateCopyWith(FeedItemState value, $Res Function(FeedItemState) _then) = _$FeedItemStateCopyWithImpl;
@useResult
$Res call({
 String id, BlocStatus<FeedItemEntity> detailState, BlocStatus<List<FeedItemEntity>> relatedState, bool isSaved, int saveToggles
});


$BlocStatusCopyWith<FeedItemEntity, $Res> get detailState;$BlocStatusCopyWith<List<FeedItemEntity>, $Res> get relatedState;

}
/// @nodoc
class _$FeedItemStateCopyWithImpl<$Res>
    implements $FeedItemStateCopyWith<$Res> {
  _$FeedItemStateCopyWithImpl(this._self, this._then);

  final FeedItemState _self;
  final $Res Function(FeedItemState) _then;

/// Create a copy of FeedItemState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? detailState = null,Object? relatedState = null,Object? isSaved = null,Object? saveToggles = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,detailState: null == detailState ? _self.detailState : detailState // ignore: cast_nullable_to_non_nullable
as BlocStatus<FeedItemEntity>,relatedState: null == relatedState ? _self.relatedState : relatedState // ignore: cast_nullable_to_non_nullable
as BlocStatus<List<FeedItemEntity>>,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,saveToggles: null == saveToggles ? _self.saveToggles : saveToggles // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of FeedItemState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlocStatusCopyWith<FeedItemEntity, $Res> get detailState {
  
  return $BlocStatusCopyWith<FeedItemEntity, $Res>(_self.detailState, (value) {
    return _then(_self.copyWith(detailState: value));
  });
}/// Create a copy of FeedItemState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlocStatusCopyWith<List<FeedItemEntity>, $Res> get relatedState {
  
  return $BlocStatusCopyWith<List<FeedItemEntity>, $Res>(_self.relatedState, (value) {
    return _then(_self.copyWith(relatedState: value));
  });
}
}


/// Adds pattern-matching-related methods to [FeedItemState].
extension FeedItemStatePatterns on FeedItemState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedItemState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedItemState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedItemState value)  $default,){
final _that = this;
switch (_that) {
case _FeedItemState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedItemState value)?  $default,){
final _that = this;
switch (_that) {
case _FeedItemState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  BlocStatus<FeedItemEntity> detailState,  BlocStatus<List<FeedItemEntity>> relatedState,  bool isSaved,  int saveToggles)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedItemState() when $default != null:
return $default(_that.id,_that.detailState,_that.relatedState,_that.isSaved,_that.saveToggles);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  BlocStatus<FeedItemEntity> detailState,  BlocStatus<List<FeedItemEntity>> relatedState,  bool isSaved,  int saveToggles)  $default,) {final _that = this;
switch (_that) {
case _FeedItemState():
return $default(_that.id,_that.detailState,_that.relatedState,_that.isSaved,_that.saveToggles);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  BlocStatus<FeedItemEntity> detailState,  BlocStatus<List<FeedItemEntity>> relatedState,  bool isSaved,  int saveToggles)?  $default,) {final _that = this;
switch (_that) {
case _FeedItemState() when $default != null:
return $default(_that.id,_that.detailState,_that.relatedState,_that.isSaved,_that.saveToggles);case _:
  return null;

}
}

}

/// @nodoc


class _FeedItemState implements FeedItemState {
  const _FeedItemState({this.id = '', this.detailState = const BlocStatus<FeedItemEntity>.initial(), this.relatedState = const BlocStatus<List<FeedItemEntity>>.initial(), this.isSaved = false, this.saveToggles = 0});
  

@override@JsonKey() final  String id;
@override@JsonKey() final  BlocStatus<FeedItemEntity> detailState;
/// «More like this»: the same category, this item left out.
@override@JsonKey() final  BlocStatus<List<FeedItemEntity>> relatedState;
@override@JsonKey() final  bool isSaved;
/// Bumped on every save toggle, so the page can react to the SAME value
/// twice (save, undo, save).
@override@JsonKey() final  int saveToggles;

/// Create a copy of FeedItemState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedItemStateCopyWith<_FeedItemState> get copyWith => __$FeedItemStateCopyWithImpl<_FeedItemState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedItemState&&(identical(other.id, id) || other.id == id)&&(identical(other.detailState, detailState) || other.detailState == detailState)&&(identical(other.relatedState, relatedState) || other.relatedState == relatedState)&&(identical(other.isSaved, isSaved) || other.isSaved == isSaved)&&(identical(other.saveToggles, saveToggles) || other.saveToggles == saveToggles));
}


@override
int get hashCode => Object.hash(runtimeType,id,detailState,relatedState,isSaved,saveToggles);

@override
String toString() {
  return 'FeedItemState(id: $id, detailState: $detailState, relatedState: $relatedState, isSaved: $isSaved, saveToggles: $saveToggles)';
}


}

/// @nodoc
abstract mixin class _$FeedItemStateCopyWith<$Res> implements $FeedItemStateCopyWith<$Res> {
  factory _$FeedItemStateCopyWith(_FeedItemState value, $Res Function(_FeedItemState) _then) = __$FeedItemStateCopyWithImpl;
@override @useResult
$Res call({
 String id, BlocStatus<FeedItemEntity> detailState, BlocStatus<List<FeedItemEntity>> relatedState, bool isSaved, int saveToggles
});


@override $BlocStatusCopyWith<FeedItemEntity, $Res> get detailState;@override $BlocStatusCopyWith<List<FeedItemEntity>, $Res> get relatedState;

}
/// @nodoc
class __$FeedItemStateCopyWithImpl<$Res>
    implements _$FeedItemStateCopyWith<$Res> {
  __$FeedItemStateCopyWithImpl(this._self, this._then);

  final _FeedItemState _self;
  final $Res Function(_FeedItemState) _then;

/// Create a copy of FeedItemState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? detailState = null,Object? relatedState = null,Object? isSaved = null,Object? saveToggles = null,}) {
  return _then(_FeedItemState(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,detailState: null == detailState ? _self.detailState : detailState // ignore: cast_nullable_to_non_nullable
as BlocStatus<FeedItemEntity>,relatedState: null == relatedState ? _self.relatedState : relatedState // ignore: cast_nullable_to_non_nullable
as BlocStatus<List<FeedItemEntity>>,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,saveToggles: null == saveToggles ? _self.saveToggles : saveToggles // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of FeedItemState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlocStatusCopyWith<FeedItemEntity, $Res> get detailState {
  
  return $BlocStatusCopyWith<FeedItemEntity, $Res>(_self.detailState, (value) {
    return _then(_self.copyWith(detailState: value));
  });
}/// Create a copy of FeedItemState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlocStatusCopyWith<List<FeedItemEntity>, $Res> get relatedState {
  
  return $BlocStatusCopyWith<List<FeedItemEntity>, $Res>(_self.relatedState, (value) {
    return _then(_self.copyWith(relatedState: value));
  });
}
}

// dart format on
