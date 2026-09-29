// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FeedEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FeedEvent()';
}


}

/// @nodoc
class $FeedEventCopyWith<$Res>  {
$FeedEventCopyWith(FeedEvent _, $Res Function(FeedEvent) __);
}


/// Adds pattern-matching-related methods to [FeedEvent].
extension FeedEventPatterns on FeedEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Started value)?  started,TResult Function( _SectionRequested value)?  sectionRequested,TResult Function( _SectionRetried value)?  sectionRetried,TResult Function( _ListRetried value)?  listRetried,TResult Function( _Refreshed value)?  refreshed,TResult Function( _LoadMore value)?  loadMore,TResult Function( _QuerySubmitted value)?  querySubmitted,TResult Function( _Scrolled value)?  scrolled,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _SectionRequested() when sectionRequested != null:
return sectionRequested(_that);case _SectionRetried() when sectionRetried != null:
return sectionRetried(_that);case _ListRetried() when listRetried != null:
return listRetried(_that);case _Refreshed() when refreshed != null:
return refreshed(_that);case _LoadMore() when loadMore != null:
return loadMore(_that);case _QuerySubmitted() when querySubmitted != null:
return querySubmitted(_that);case _Scrolled() when scrolled != null:
return scrolled(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Started value)  started,required TResult Function( _SectionRequested value)  sectionRequested,required TResult Function( _SectionRetried value)  sectionRetried,required TResult Function( _ListRetried value)  listRetried,required TResult Function( _Refreshed value)  refreshed,required TResult Function( _LoadMore value)  loadMore,required TResult Function( _QuerySubmitted value)  querySubmitted,required TResult Function( _Scrolled value)  scrolled,}){
final _that = this;
switch (_that) {
case _Started():
return started(_that);case _SectionRequested():
return sectionRequested(_that);case _SectionRetried():
return sectionRetried(_that);case _ListRetried():
return listRetried(_that);case _Refreshed():
return refreshed(_that);case _LoadMore():
return loadMore(_that);case _QuerySubmitted():
return querySubmitted(_that);case _Scrolled():
return scrolled(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Started value)?  started,TResult? Function( _SectionRequested value)?  sectionRequested,TResult? Function( _SectionRetried value)?  sectionRetried,TResult? Function( _ListRetried value)?  listRetried,TResult? Function( _Refreshed value)?  refreshed,TResult? Function( _LoadMore value)?  loadMore,TResult? Function( _QuerySubmitted value)?  querySubmitted,TResult? Function( _Scrolled value)?  scrolled,}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _SectionRequested() when sectionRequested != null:
return sectionRequested(_that);case _SectionRetried() when sectionRetried != null:
return sectionRetried(_that);case _ListRetried() when listRetried != null:
return listRetried(_that);case _Refreshed() when refreshed != null:
return refreshed(_that);case _LoadMore() when loadMore != null:
return loadMore(_that);case _QuerySubmitted() when querySubmitted != null:
return querySubmitted(_that);case _Scrolled() when scrolled != null:
return scrolled(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function( FeedSection section)?  sectionRequested,TResult Function( FeedSection section)?  sectionRetried,TResult Function()?  listRetried,TResult Function()?  refreshed,TResult Function()?  loadMore,TResult Function( String query)?  querySubmitted,TResult Function( double offset)?  scrolled,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _SectionRequested() when sectionRequested != null:
return sectionRequested(_that.section);case _SectionRetried() when sectionRetried != null:
return sectionRetried(_that.section);case _ListRetried() when listRetried != null:
return listRetried();case _Refreshed() when refreshed != null:
return refreshed();case _LoadMore() when loadMore != null:
return loadMore();case _QuerySubmitted() when querySubmitted != null:
return querySubmitted(_that.query);case _Scrolled() when scrolled != null:
return scrolled(_that.offset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function( FeedSection section)  sectionRequested,required TResult Function( FeedSection section)  sectionRetried,required TResult Function()  listRetried,required TResult Function()  refreshed,required TResult Function()  loadMore,required TResult Function( String query)  querySubmitted,required TResult Function( double offset)  scrolled,}) {final _that = this;
switch (_that) {
case _Started():
return started();case _SectionRequested():
return sectionRequested(_that.section);case _SectionRetried():
return sectionRetried(_that.section);case _ListRetried():
return listRetried();case _Refreshed():
return refreshed();case _LoadMore():
return loadMore();case _QuerySubmitted():
return querySubmitted(_that.query);case _Scrolled():
return scrolled(_that.offset);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function( FeedSection section)?  sectionRequested,TResult? Function( FeedSection section)?  sectionRetried,TResult? Function()?  listRetried,TResult? Function()?  refreshed,TResult? Function()?  loadMore,TResult? Function( String query)?  querySubmitted,TResult? Function( double offset)?  scrolled,}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _SectionRequested() when sectionRequested != null:
return sectionRequested(_that.section);case _SectionRetried() when sectionRetried != null:
return sectionRetried(_that.section);case _ListRetried() when listRetried != null:
return listRetried();case _Refreshed() when refreshed != null:
return refreshed();case _LoadMore() when loadMore != null:
return loadMore();case _QuerySubmitted() when querySubmitted != null:
return querySubmitted(_that.query);case _Scrolled() when scrolled != null:
return scrolled(_that.offset);case _:
  return null;

}
}

}

/// @nodoc


class _Started implements FeedEvent {
  const _Started();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Started);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FeedEvent.started()';
}


}




/// @nodoc


class _SectionRequested implements FeedEvent {
  const _SectionRequested(this.section);
  

 final  FeedSection section;

/// Create a copy of FeedEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SectionRequestedCopyWith<_SectionRequested> get copyWith => __$SectionRequestedCopyWithImpl<_SectionRequested>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SectionRequested&&(identical(other.section, section) || other.section == section));
}


@override
int get hashCode => Object.hash(runtimeType,section);

@override
String toString() {
  return 'FeedEvent.sectionRequested(section: $section)';
}


}

/// @nodoc
abstract mixin class _$SectionRequestedCopyWith<$Res> implements $FeedEventCopyWith<$Res> {
  factory _$SectionRequestedCopyWith(_SectionRequested value, $Res Function(_SectionRequested) _then) = __$SectionRequestedCopyWithImpl;
@useResult
$Res call({
 FeedSection section
});




}
/// @nodoc
class __$SectionRequestedCopyWithImpl<$Res>
    implements _$SectionRequestedCopyWith<$Res> {
  __$SectionRequestedCopyWithImpl(this._self, this._then);

  final _SectionRequested _self;
  final $Res Function(_SectionRequested) _then;

/// Create a copy of FeedEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? section = null,}) {
  return _then(_SectionRequested(
null == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as FeedSection,
  ));
}


}

/// @nodoc


class _SectionRetried implements FeedEvent {
  const _SectionRetried(this.section);
  

 final  FeedSection section;

/// Create a copy of FeedEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SectionRetriedCopyWith<_SectionRetried> get copyWith => __$SectionRetriedCopyWithImpl<_SectionRetried>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SectionRetried&&(identical(other.section, section) || other.section == section));
}


@override
int get hashCode => Object.hash(runtimeType,section);

@override
String toString() {
  return 'FeedEvent.sectionRetried(section: $section)';
}


}

/// @nodoc
abstract mixin class _$SectionRetriedCopyWith<$Res> implements $FeedEventCopyWith<$Res> {
  factory _$SectionRetriedCopyWith(_SectionRetried value, $Res Function(_SectionRetried) _then) = __$SectionRetriedCopyWithImpl;
@useResult
$Res call({
 FeedSection section
});




}
/// @nodoc
class __$SectionRetriedCopyWithImpl<$Res>
    implements _$SectionRetriedCopyWith<$Res> {
  __$SectionRetriedCopyWithImpl(this._self, this._then);

  final _SectionRetried _self;
  final $Res Function(_SectionRetried) _then;

/// Create a copy of FeedEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? section = null,}) {
  return _then(_SectionRetried(
null == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as FeedSection,
  ));
}


}

/// @nodoc


class _ListRetried implements FeedEvent {
  const _ListRetried();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListRetried);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FeedEvent.listRetried()';
}


}




/// @nodoc


class _Refreshed implements FeedEvent {
  const _Refreshed();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Refreshed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FeedEvent.refreshed()';
}


}




/// @nodoc


class _LoadMore implements FeedEvent {
  const _LoadMore();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadMore);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FeedEvent.loadMore()';
}


}




/// @nodoc


class _QuerySubmitted implements FeedEvent {
  const _QuerySubmitted(this.query);
  

 final  String query;

/// Create a copy of FeedEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuerySubmittedCopyWith<_QuerySubmitted> get copyWith => __$QuerySubmittedCopyWithImpl<_QuerySubmitted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuerySubmitted&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,query);

@override
String toString() {
  return 'FeedEvent.querySubmitted(query: $query)';
}


}

/// @nodoc
abstract mixin class _$QuerySubmittedCopyWith<$Res> implements $FeedEventCopyWith<$Res> {
  factory _$QuerySubmittedCopyWith(_QuerySubmitted value, $Res Function(_QuerySubmitted) _then) = __$QuerySubmittedCopyWithImpl;
@useResult
$Res call({
 String query
});




}
/// @nodoc
class __$QuerySubmittedCopyWithImpl<$Res>
    implements _$QuerySubmittedCopyWith<$Res> {
  __$QuerySubmittedCopyWithImpl(this._self, this._then);

  final _QuerySubmitted _self;
  final $Res Function(_QuerySubmitted) _then;

/// Create a copy of FeedEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? query = null,}) {
  return _then(_QuerySubmitted(
null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Scrolled implements FeedEvent {
  const _Scrolled(this.offset);
  

 final  double offset;

/// Create a copy of FeedEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScrolledCopyWith<_Scrolled> get copyWith => __$ScrolledCopyWithImpl<_Scrolled>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Scrolled&&(identical(other.offset, offset) || other.offset == offset));
}


@override
int get hashCode => Object.hash(runtimeType,offset);

@override
String toString() {
  return 'FeedEvent.scrolled(offset: $offset)';
}


}

/// @nodoc
abstract mixin class _$ScrolledCopyWith<$Res> implements $FeedEventCopyWith<$Res> {
  factory _$ScrolledCopyWith(_Scrolled value, $Res Function(_Scrolled) _then) = __$ScrolledCopyWithImpl;
@useResult
$Res call({
 double offset
});




}
/// @nodoc
class __$ScrolledCopyWithImpl<$Res>
    implements _$ScrolledCopyWith<$Res> {
  __$ScrolledCopyWithImpl(this._self, this._then);

  final _Scrolled _self;
  final $Res Function(_Scrolled) _then;

/// Create a copy of FeedEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? offset = null,}) {
  return _then(_Scrolled(
null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$FeedState {

 BlocStatus<List<FeedItemEntity>> get highlightsState; BlocStatus<List<FeedItemEntity>> get picksState;/// The paged list, every page loaded so far.
 BlocStatus<List<FeedItemEntity>> get listState;/// The next page — kept apart so a failed next page never empties the
/// list on screen.
 BlocStatus<void> get loadMoreState; int get page; bool get hasMore; int get total; String get query; List<String> get recentSearches; bool get isSearchVisible;
/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedStateCopyWith<FeedState> get copyWith => _$FeedStateCopyWithImpl<FeedState>(this as FeedState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedState&&(identical(other.highlightsState, highlightsState) || other.highlightsState == highlightsState)&&(identical(other.picksState, picksState) || other.picksState == picksState)&&(identical(other.listState, listState) || other.listState == listState)&&(identical(other.loadMoreState, loadMoreState) || other.loadMoreState == loadMoreState)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.total, total) || other.total == total)&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other.recentSearches, recentSearches)&&(identical(other.isSearchVisible, isSearchVisible) || other.isSearchVisible == isSearchVisible));
}


@override
int get hashCode => Object.hash(runtimeType,highlightsState,picksState,listState,loadMoreState,page,hasMore,total,query,const DeepCollectionEquality().hash(recentSearches),isSearchVisible);

@override
String toString() {
  return 'FeedState(highlightsState: $highlightsState, picksState: $picksState, listState: $listState, loadMoreState: $loadMoreState, page: $page, hasMore: $hasMore, total: $total, query: $query, recentSearches: $recentSearches, isSearchVisible: $isSearchVisible)';
}


}

/// @nodoc
abstract mixin class $FeedStateCopyWith<$Res>  {
  factory $FeedStateCopyWith(FeedState value, $Res Function(FeedState) _then) = _$FeedStateCopyWithImpl;
@useResult
$Res call({
 BlocStatus<List<FeedItemEntity>> highlightsState, BlocStatus<List<FeedItemEntity>> picksState, BlocStatus<List<FeedItemEntity>> listState, BlocStatus<void> loadMoreState, int page, bool hasMore, int total, String query, List<String> recentSearches, bool isSearchVisible
});


$BlocStatusCopyWith<List<FeedItemEntity>, $Res> get highlightsState;$BlocStatusCopyWith<List<FeedItemEntity>, $Res> get picksState;$BlocStatusCopyWith<List<FeedItemEntity>, $Res> get listState;$BlocStatusCopyWith<void, $Res> get loadMoreState;

}
/// @nodoc
class _$FeedStateCopyWithImpl<$Res>
    implements $FeedStateCopyWith<$Res> {
  _$FeedStateCopyWithImpl(this._self, this._then);

  final FeedState _self;
  final $Res Function(FeedState) _then;

/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? highlightsState = null,Object? picksState = null,Object? listState = null,Object? loadMoreState = null,Object? page = null,Object? hasMore = null,Object? total = null,Object? query = null,Object? recentSearches = null,Object? isSearchVisible = null,}) {
  return _then(_self.copyWith(
highlightsState: null == highlightsState ? _self.highlightsState : highlightsState // ignore: cast_nullable_to_non_nullable
as BlocStatus<List<FeedItemEntity>>,picksState: null == picksState ? _self.picksState : picksState // ignore: cast_nullable_to_non_nullable
as BlocStatus<List<FeedItemEntity>>,listState: null == listState ? _self.listState : listState // ignore: cast_nullable_to_non_nullable
as BlocStatus<List<FeedItemEntity>>,loadMoreState: null == loadMoreState ? _self.loadMoreState : loadMoreState // ignore: cast_nullable_to_non_nullable
as BlocStatus<void>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,recentSearches: null == recentSearches ? _self.recentSearches : recentSearches // ignore: cast_nullable_to_non_nullable
as List<String>,isSearchVisible: null == isSearchVisible ? _self.isSearchVisible : isSearchVisible // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlocStatusCopyWith<List<FeedItemEntity>, $Res> get highlightsState {
  
  return $BlocStatusCopyWith<List<FeedItemEntity>, $Res>(_self.highlightsState, (value) {
    return _then(_self.copyWith(highlightsState: value));
  });
}/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlocStatusCopyWith<List<FeedItemEntity>, $Res> get picksState {
  
  return $BlocStatusCopyWith<List<FeedItemEntity>, $Res>(_self.picksState, (value) {
    return _then(_self.copyWith(picksState: value));
  });
}/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlocStatusCopyWith<List<FeedItemEntity>, $Res> get listState {
  
  return $BlocStatusCopyWith<List<FeedItemEntity>, $Res>(_self.listState, (value) {
    return _then(_self.copyWith(listState: value));
  });
}/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlocStatusCopyWith<void, $Res> get loadMoreState {
  
  return $BlocStatusCopyWith<void, $Res>(_self.loadMoreState, (value) {
    return _then(_self.copyWith(loadMoreState: value));
  });
}
}


/// Adds pattern-matching-related methods to [FeedState].
extension FeedStatePatterns on FeedState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedState value)  $default,){
final _that = this;
switch (_that) {
case _FeedState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedState value)?  $default,){
final _that = this;
switch (_that) {
case _FeedState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BlocStatus<List<FeedItemEntity>> highlightsState,  BlocStatus<List<FeedItemEntity>> picksState,  BlocStatus<List<FeedItemEntity>> listState,  BlocStatus<void> loadMoreState,  int page,  bool hasMore,  int total,  String query,  List<String> recentSearches,  bool isSearchVisible)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedState() when $default != null:
return $default(_that.highlightsState,_that.picksState,_that.listState,_that.loadMoreState,_that.page,_that.hasMore,_that.total,_that.query,_that.recentSearches,_that.isSearchVisible);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BlocStatus<List<FeedItemEntity>> highlightsState,  BlocStatus<List<FeedItemEntity>> picksState,  BlocStatus<List<FeedItemEntity>> listState,  BlocStatus<void> loadMoreState,  int page,  bool hasMore,  int total,  String query,  List<String> recentSearches,  bool isSearchVisible)  $default,) {final _that = this;
switch (_that) {
case _FeedState():
return $default(_that.highlightsState,_that.picksState,_that.listState,_that.loadMoreState,_that.page,_that.hasMore,_that.total,_that.query,_that.recentSearches,_that.isSearchVisible);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BlocStatus<List<FeedItemEntity>> highlightsState,  BlocStatus<List<FeedItemEntity>> picksState,  BlocStatus<List<FeedItemEntity>> listState,  BlocStatus<void> loadMoreState,  int page,  bool hasMore,  int total,  String query,  List<String> recentSearches,  bool isSearchVisible)?  $default,) {final _that = this;
switch (_that) {
case _FeedState() when $default != null:
return $default(_that.highlightsState,_that.picksState,_that.listState,_that.loadMoreState,_that.page,_that.hasMore,_that.total,_that.query,_that.recentSearches,_that.isSearchVisible);case _:
  return null;

}
}

}

/// @nodoc


class _FeedState implements FeedState {
  const _FeedState({this.highlightsState = const BlocStatus<List<FeedItemEntity>>.initial(), this.picksState = const BlocStatus<List<FeedItemEntity>>.initial(), this.listState = const BlocStatus<List<FeedItemEntity>>.initial(), this.loadMoreState = const BlocStatus<void>.initial(), this.page = 1, this.hasMore = false, this.total = 0, this.query = '', final  List<String> recentSearches = const <String>[], this.isSearchVisible = true}): _recentSearches = recentSearches;
  

@override@JsonKey() final  BlocStatus<List<FeedItemEntity>> highlightsState;
@override@JsonKey() final  BlocStatus<List<FeedItemEntity>> picksState;
/// The paged list, every page loaded so far.
@override@JsonKey() final  BlocStatus<List<FeedItemEntity>> listState;
/// The next page — kept apart so a failed next page never empties the
/// list on screen.
@override@JsonKey() final  BlocStatus<void> loadMoreState;
@override@JsonKey() final  int page;
@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  int total;
@override@JsonKey() final  String query;
 final  List<String> _recentSearches;
@override@JsonKey() List<String> get recentSearches {
  if (_recentSearches is EqualUnmodifiableListView) return _recentSearches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentSearches);
}

@override@JsonKey() final  bool isSearchVisible;

/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedStateCopyWith<_FeedState> get copyWith => __$FeedStateCopyWithImpl<_FeedState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedState&&(identical(other.highlightsState, highlightsState) || other.highlightsState == highlightsState)&&(identical(other.picksState, picksState) || other.picksState == picksState)&&(identical(other.listState, listState) || other.listState == listState)&&(identical(other.loadMoreState, loadMoreState) || other.loadMoreState == loadMoreState)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.total, total) || other.total == total)&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other._recentSearches, _recentSearches)&&(identical(other.isSearchVisible, isSearchVisible) || other.isSearchVisible == isSearchVisible));
}


@override
int get hashCode => Object.hash(runtimeType,highlightsState,picksState,listState,loadMoreState,page,hasMore,total,query,const DeepCollectionEquality().hash(_recentSearches),isSearchVisible);

@override
String toString() {
  return 'FeedState(highlightsState: $highlightsState, picksState: $picksState, listState: $listState, loadMoreState: $loadMoreState, page: $page, hasMore: $hasMore, total: $total, query: $query, recentSearches: $recentSearches, isSearchVisible: $isSearchVisible)';
}


}

/// @nodoc
abstract mixin class _$FeedStateCopyWith<$Res> implements $FeedStateCopyWith<$Res> {
  factory _$FeedStateCopyWith(_FeedState value, $Res Function(_FeedState) _then) = __$FeedStateCopyWithImpl;
@override @useResult
$Res call({
 BlocStatus<List<FeedItemEntity>> highlightsState, BlocStatus<List<FeedItemEntity>> picksState, BlocStatus<List<FeedItemEntity>> listState, BlocStatus<void> loadMoreState, int page, bool hasMore, int total, String query, List<String> recentSearches, bool isSearchVisible
});


@override $BlocStatusCopyWith<List<FeedItemEntity>, $Res> get highlightsState;@override $BlocStatusCopyWith<List<FeedItemEntity>, $Res> get picksState;@override $BlocStatusCopyWith<List<FeedItemEntity>, $Res> get listState;@override $BlocStatusCopyWith<void, $Res> get loadMoreState;

}
/// @nodoc
class __$FeedStateCopyWithImpl<$Res>
    implements _$FeedStateCopyWith<$Res> {
  __$FeedStateCopyWithImpl(this._self, this._then);

  final _FeedState _self;
  final $Res Function(_FeedState) _then;

/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? highlightsState = null,Object? picksState = null,Object? listState = null,Object? loadMoreState = null,Object? page = null,Object? hasMore = null,Object? total = null,Object? query = null,Object? recentSearches = null,Object? isSearchVisible = null,}) {
  return _then(_FeedState(
highlightsState: null == highlightsState ? _self.highlightsState : highlightsState // ignore: cast_nullable_to_non_nullable
as BlocStatus<List<FeedItemEntity>>,picksState: null == picksState ? _self.picksState : picksState // ignore: cast_nullable_to_non_nullable
as BlocStatus<List<FeedItemEntity>>,listState: null == listState ? _self.listState : listState // ignore: cast_nullable_to_non_nullable
as BlocStatus<List<FeedItemEntity>>,loadMoreState: null == loadMoreState ? _self.loadMoreState : loadMoreState // ignore: cast_nullable_to_non_nullable
as BlocStatus<void>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,recentSearches: null == recentSearches ? _self._recentSearches : recentSearches // ignore: cast_nullable_to_non_nullable
as List<String>,isSearchVisible: null == isSearchVisible ? _self.isSearchVisible : isSearchVisible // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlocStatusCopyWith<List<FeedItemEntity>, $Res> get highlightsState {
  
  return $BlocStatusCopyWith<List<FeedItemEntity>, $Res>(_self.highlightsState, (value) {
    return _then(_self.copyWith(highlightsState: value));
  });
}/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlocStatusCopyWith<List<FeedItemEntity>, $Res> get picksState {
  
  return $BlocStatusCopyWith<List<FeedItemEntity>, $Res>(_self.picksState, (value) {
    return _then(_self.copyWith(picksState: value));
  });
}/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlocStatusCopyWith<List<FeedItemEntity>, $Res> get listState {
  
  return $BlocStatusCopyWith<List<FeedItemEntity>, $Res>(_self.listState, (value) {
    return _then(_self.copyWith(listState: value));
  });
}/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlocStatusCopyWith<void, $Res> get loadMoreState {
  
  return $BlocStatusCopyWith<void, $Res>(_self.loadMoreState, (value) {
    return _then(_self.copyWith(loadMoreState: value));
  });
}
}

// dart format on
