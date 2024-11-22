import { AbstractControl, ValidationErrors } from '@angular/forms';

export function notOnlyWhitespaceValidator(control: AbstractControl): ValidationErrors | null {
    return (control.value && control.value.trim().length === 0) ? { 'onlyWhitespace': true } : null;
}