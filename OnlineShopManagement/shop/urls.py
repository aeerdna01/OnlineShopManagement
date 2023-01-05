from django.urls import path
from . import views

urlpatterns = [
    path('', views.login_shop, name='login_shop'),
    path('register/', views.register_shop, name='register_shop'),
    path('home/', views.home, name='home'),
    path('home/<int:product_id>/edit/', views.edit_product, name='edit_product'),

]
