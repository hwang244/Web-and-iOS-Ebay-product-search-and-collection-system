import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormControl, FormGroup, FormArray,Validators } from '@angular/forms';
import { notOnlyWhitespaceValidator } from './validators/not-only-whitespace-validator';
import { debounceTime, distinctUntilChanged, filter,switchMap } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { LocationService } from './services/location.service';
import { AutolocationService } from './services/autolocation.service';
import { SearchService } from './services/search.service';
import { SharedSearchResultsService } from 'src/app/services/shared-search-results.service';

@Component({
  selector: 'app-product-search',
  templateUrl: './product-search.component.html',
  styleUrls: ['./product-search.component.css']
})
export class ProductSearchComponent {
  form!: FormGroup;
  filteredZipcodes$: Observable<string[]> = new Observable<string[]>();

  constructor(private fb: FormBuilder, 
              private locationService: LocationService, 
              private autoLocService: AutolocationService,
              private searchService: SearchService,
              private shSrchReService: SharedSearchResultsService){
  }
  ngOnInit():void{
    this.form = this.fb.group({
      keyword: ['', [Validators.required, notOnlyWhitespaceValidator]],
      category: [''],
      selectedConditions: this.fb.array([]),
      selectedShippings: this.fb.array([]),
      distance: [''],
      zipcode: ['', [Validators.required, notOnlyWhitespaceValidator, Validators.pattern(/^\d{5}$/)]],
      locationChoice:[''],
    });
    this.setCurrentLocation();
    this.setZipcodeAutoComplete();
    this.listenToLocationChoiceChanges();
  }


  setCurrentLocation() {
    this.form.get('locationChoice')!.setValue('current');
    this.locationService.getUserLocation().subscribe({
      next: data => {
        if (data && "postal" in data) {
          this.form.controls['zipcode'].setValue(data.postal);
        }  
      },
      error: error => {
        console.error("There was an error getting the location data", error);
      }
    });
  }
  setZipcodeAutoComplete(){
    this.filteredZipcodes$ = this.form.get('zipcode')!.valueChanges.pipe(
      debounceTime(2000),
      distinctUntilChanged(),
      filter(value => 
        this.form.get('locationChoice')!.value === 'other' && 
        value && 
        typeof value === 'string' &&
        value.length >= 3
      ),
      switchMap(value => this.autoLocService.getPostalCodes(value))
    );
  }

  clearZipcode() {
    if (this.form.get('locationChoice')!.value === 'other') {
      this.form.get('zipcode')!.setValue('');
      this.form
    }
  }
  listenToLocationChoiceChanges() {
    this.form.get('locationChoice')!.valueChanges.subscribe(() => {
      this.clearZipcode();
    });
  }
  

  get selectedConditions() {
    return this.form.get('selectedConditions') as FormArray;
  }

  get selectedShippings(){
    return this.form.get('selectedShippings') as FormArray;
  }

  onConditionChange(e:any) {
    if (e.target.checked) {
      this.selectedConditions.push(new FormControl(e.target.value));
    } else {
      const index = this.selectedConditions.controls.findIndex(x => x.value === e.target.value);
      this.selectedConditions.removeAt(index);
    }
  }

  onShippingChange(e:any) {
    if (e.target.checked) {
      this.selectedShippings.push(new FormControl(e.target.value));
    } else {
      const index = this.selectedShippings.controls.findIndex(x => x.value === e.target.value);
      this.selectedShippings.removeAt(index);
    }
  }

  onLocationChange(event: any) {
    if (event.target.checked) {
      this.setCurrentLocation();
    }
  }
  onSubmit(){
    console.log(this.form.controls['keyword'].errors);
    console.log(this.form.controls['zipcode'].errors);
    if(this.form.valid){
      console.log(this.form.value);
      this.searchService.performSearch(
        this.form.value.keyword,
        this.form.value.category,
        this.form.value.selectedConditions,
        this.form.value.selectedShippings,
        this.form.value.distance,
        this.form.value.zipcode
      ).subscribe({
        next: (response) => {
          // Handle the response
          this.shSrchReService.setSearchArray(response);
        },
        error: (error) => {
          // Handle the error
          console.error(error);
        }
      });
    }else{
      console.error('Form is not valid.');
    }
  }
  clearForm() {
    // Reset the form using the FormBuilder group to reset custom validators
    this.form = this.fb.group({
      keyword: ['', [Validators.required, notOnlyWhitespaceValidator]],
      category: [''],
      selectedConditions: this.fb.array([]),
      selectedShippings: this.fb.array([]),
      distance: [''],
      zipcode: ['', [Validators.required, notOnlyWhitespaceValidator, Validators.pattern(/^\d{5}$/)]],
      locationChoice:['current'],
    });
  
    // Reset other state-related variables if necessary
  
    // Clear the search results by informing the SharedSearchResultsService
    this.shSrchReService.setSearchArray([]); // Pass an empty array to indicate no results
    // You can also consider adding a method in SharedSearchResultsService to handle this
  }

}
