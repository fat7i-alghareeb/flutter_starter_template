import 'package:reactive_forms/reactive_forms.dart';

extension FormGroupControlX on FormGroup {
  FormControl<T> controlOf<T>(String name) => control(name) as FormControl<T>;

  T? valueOf<T>(String name) => control(name).value as T?;

  void setValueOf<T>(String name, T? value) {
    final c = controlOf<T>(name);
    c.updateValue(value);
  }

  bool get areAllControlsValid => controls.values.every((c) => c.valid);

  void validateAll() {
    markAllAsTouched();
    for (final c in controls.values) {
      _markControlDirtyRecursive(c);
    }
    updateValueAndValidity();
  }

  void _markControlDirtyRecursive(AbstractControl<dynamic> control) {
    control.markAsDirty();

    if (control is FormGroup) {
      for (final child in control.controls.values) {
        _markControlDirtyRecursive(child);
      }
    }

    if (control is FormArray) {
      for (final child in control.controls) {
        _markControlDirtyRecursive(child);
      }
    }
  }

  void resetAllTouched() {
    for (final c in controls.values) {
      _resetControlTouchedRecursive(c);
    }
  }

  void _resetControlTouchedRecursive(AbstractControl<dynamic> control) {
    control.markAsUntouched();

    if (control is FormGroup) {
      for (final child in control.controls.values) {
        _resetControlTouchedRecursive(child);
      }
    }

    if (control is FormArray) {
      for (final child in control.controls) {
        _resetControlTouchedRecursive(child);
      }
    }
  }
}

extension FormControlX<T> on FormControl<T> {
  void touch() => markAsTouched();
}
