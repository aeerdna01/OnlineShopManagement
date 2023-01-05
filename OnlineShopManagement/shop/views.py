import cx_Oracle
from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.template import loader
from shop.connect import connection
from django import forms
from shop.forms import EditProductForm
from shop.utils import get_categories

# Global variable to determine which user is authenticated
id_client = None
# Global variable to determine which product is edited
product_to_edit = None


# Manage the login page
def login_shop(request):
    global id_client

    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']

        # Query the database to check if the user exists
        cursor = connection.cursor()
        cursor.execute("SELECT * FROM accounts WHERE username = :username AND password = :password",
                       username=username, password=password)
        client = cursor.fetchone()

        # If the user exists, log the user in and redirect to the home page
        if client:
            id_client = client[0]
            return redirect('home')
        # Otherwise, render the login template with an error message
        else:
            return render(request, 'registration/login.html', {'errors': 'Invalid username or password.'})

    # If the request is not a POST request, render the login template
    else:
        return render(request, 'registration/login.html')


# Temporary code to verify if the insert works
# username = 'maria'
# password = 'Hello@2021'
# role = 'customer'
cursor = connection.cursor()
# cursor.execute("INSERT INTO accounts (username, password, role) VALUES (:1, :2, :3)", (username, password, role))
cursor.execute("SELECT * FROM accounts")
rows = cursor.fetchall()
for row in rows:
    print(row)


# Manage the register page
def register_shop(request):
    if request.method == 'POST':
        first_name = request.POST['firstname']
        last_name = request.POST['lastname']
        email = request.POST['email']
        address = request.POST['street'] + " " + request.POST['number'] + " " + request.POST['city']
        phone = request.POST['phone']
        username = request.POST['username']
        password = request.POST['password']
        role = 'customer'

        cursor = connection.cursor()
        # Insert a record into the "accounts" table and get the ID of the inserted row

        id_out = cursor.var(cx_Oracle.NUMBER)
        cursor.execute("INSERT INTO accounts (username, password, role) VALUES (:1, :2, :3) RETURNING id_user INTO :4",
                       (username, password, role, id_out))

        # Insert a record into the "user_details" table and use the ID of the inserted row in the "accounts" table as a foreign key
        cursor.execute(
            "INSERT INTO user_details (id_user, first_name, last_name, address, email, phone) VALUES (:1, :2, :3, :4, :5, :6)",
            (id_out.getvalue()[0], first_name, last_name, address, email, phone))
        cursor.execute("commit")
        return redirect('login_shop')
    # If the request is not a POST request, render the register template
    else:
        return render(request, 'registration/register.html')
    return render(request, 'registration/register.html')


# Update the product in the database
def edit_product(request, product_id):
    # Retrieve the product from the database
    global product_to_edit
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM products WHERE id_product = :id", {'id': product_id})
    product = cursor.fetchone()
    product_to_edit = product
    product_name = ""

    if request.method == 'POST':
        form = EditProductForm(request.POST)
        if form.is_valid():
            # Requested choice for stock_quantity, price, type
            stock_quantity = form.cleaned_data['stock_quantity']
            price = form.cleaned_data['price']
            product_type = form.cleaned_data['product_type']
            product_type_label = "'" + dict(form.fields['product_type'].choices)[product_type] + "'"

            # Requested choice for category
            category = form.cleaned_data['category']
            category_type_label = "'" + dict(form.fields['category'].choices)[category] + "'"

            # Find the foreign key id_category for products table based on user choice
            cursor.execute("SELECT id_category from categories WHERE name = %s" % (category_type_label))
            category_fk = cursor.fetchone()[0]

            # Requested choice for size
            size = form.cleaned_data['size']
            size_type_label = "'" + dict(form.fields['size'].choices)[size] + "'"

            # Find the foreign key id_size for products table based on user choice
            cursor.execute("SELECT id_size from sizes WHERE name = %s" % (size_type_label))
            size_fk = cursor.fetchone()[0]

            cursor.execute("UPDATE products\
                            SET price = %s, id_category = %s, id_size = %s, type = %s WHERE id_product = %s" \
                           % (price, category_fk, size_fk, product_type_label, product_id))
            cursor.execute("commit")

            return redirect('home')
    else:
        # Render the edit form
        form = EditProductForm(initial={'stock_quantity': product[1], 'price': product[2], 'product_type': product[5],
                                        'category': 1, 'size': 1}, )

    return render(request, 'edit_product.html', {'form': form, 'product_name': product_name})


# Manage the home page
def home(request):
    global id_client

    cursor = connection.cursor()
    cursor.execute("SELECT role FROM accounts WHERE id_user = :id_client ", id_client=id_client)
    customer_type = cursor.fetchone()[0]

    cursor.execute("SELECT name FROM categories")
    categories = cursor.fetchall()
    category = request.GET.get('category')

    if category:
        cursor.execute(
            "SELECT p.id_product, p.stock_quantity, p.price, p.type, c.name, s.name FROM products p, categories c, sizes s WHERE p.id_category = c.id_category AND p.id_size = s.id_size AND c.name = :1",
            (category,))

    else:
        cursor.execute(
            "SELECT p.id_product, p.stock_quantity, p.price, p.type, c.name, s.name FROM products p, categories c, sizes s WHERE p.id_category = c.id_category AND p.id_size = s.id_size")

    products = cursor.fetchall()

    template = loader.get_template('home.html')
    return HttpResponse(template.render({'products': products, 'categories': categories}))
