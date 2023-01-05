from django import forms

from shop.utils import *


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
