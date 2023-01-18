from django.urls import path
from . import views

urlpatterns = [
    path('', views.login_shop, name='login_shop'),
    path('register/', views.register_shop, name='register_shop'),
    path('home/', views.home, name='home'),
    path('home/<int:product_id>/edit/', views.edit_product, name='edit_product'),
    path('home/add-to-cart/<int:product_id>', views.add_to_cart, name='add_to_cart'),
    path('home/view-cart/', views.view_cart, name='view_cart'),
    path('remove_from_cart/<int:product_id>/', views.remove_from_cart, name='remove_from_cart'),
    path('place-order/', views.place_order, name='place_order'),
    path('add-product/', views.add_product, name='add_product'),
    path('show_supplies/', views.show_supplies, name='show_supplies'),
    path('show_clients/', views.show_clients, name='show_clients'),
    path('show_orders/', views.show_orders, name='show_orders'),
    path('add_supply/<int:product_id>/', views.add_supply, name='add_supply'),
    path('delete_product/<int:product_id>', views.delete_product, name='delete_product'),
    path('<int:supply_id>/edit/', views.edit_supply, name='edit_supply'),

]
