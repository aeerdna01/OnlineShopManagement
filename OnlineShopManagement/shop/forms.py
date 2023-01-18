from datetime import date

from django import forms
from shop.utils import *


class SuppliesForm(forms.Form):
    supply_date = forms.DateField(widget=forms.DateInput(attrs={'class': 'datepicker'}))
    supply_quantity = forms.DecimalField(min_value=1, max_value=999)

    def clean_supply_date(self):
        supply_date = self.cleaned_data['supply_date']
        if supply_date < date.today():
            raise forms.ValidationError("Date cannot be in the past!")
        return supply_date


class ProductForm(forms.Form):
    price = forms.DecimalField(required=True, min_value=1, max_value=999)
    type = forms.ChoiceField(
        choices=[("Men", "Men"), ("Women", "Women")])
    category = forms.ChoiceField(
        choices=[("Shirts", "Shirts"), ("Jeans", "Jeans"), ("Jackets", "Jackets")])

    size = forms.ChoiceField(
        choices=[("S", "S"), ("M", "M"), ("L", "L")])


class EditProductForm(forms.Form):
    stock_quantity = forms.IntegerField(required=False, disabled=True)
    price = forms.DecimalField()
    product_type = forms.ChoiceField(widget=forms.Select)
    category = forms.ChoiceField(widget=forms.Select)
    size = forms.ChoiceField(widget=forms.Select)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['category'].choices = get_categories()
        self.fields['size'].choices = get_sizes()
        self.fields['product_type'].choices = get_types()
