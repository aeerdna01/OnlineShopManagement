from datetime import datetime

import cx_Oracle
from django.contrib import messages
from django.http import HttpResponse
from django.template import loader
from django.views.decorators.csrf import csrf_exempt

from shop.connect import connection
from shop.forms import EditProductForm, ProductForm, SuppliesForm
from django.shortcuts import render, redirect

# Global variable to determine which user is authenticated
id_client = None
# Global variable to determine which product is edited
product_to_edit = None
# Global variable to determine which product has been added to the cart and its quantity
order = {}


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


# Manage the register page
def register_shop(request):
    if request.method == 'POST':
        cursor = connection.cursor()
        email = request.POST['email']
        cursor.execute("SELECT email FROM user_details WHERE email = :email", {'email': email})
        email_exists = cursor.fetchone()
        if email_exists:
            messages.error(request, 'Email already exists!')
            return render(request, 'registration/register.html')
        else:
            first_name = request.POST['firstname']
            last_name = request.POST['lastname']
            address = request.POST['street'] + " " + request.POST['number'] + " " + request.POST['city']
            phone = request.POST['phone']
            username = request.POST['username']
            password = request.POST['password']
            role = 'customer'

            # Insert a record into the "accounts" table and get the ID of the inserted row
            id_out = cursor.var(cx_Oracle.NUMBER)
            cursor.execute(
                "INSERT INTO accounts (username, password, role) VALUES (:1, :2, :3) RETURNING id_user INTO :4",
                (username, password, role, id_out))

            # Insert a record into the "user_details" table and use the ID of the inserted row in the "accounts" table as
            # a foreign key
            cursor.execute(
                "INSERT INTO user_details (id_user, first_name, last_name, address, email, phone) VALUES (:1, :2, :3, :4, :5, :6)",
                (id_out.getvalue()[0], first_name, last_name, address, email, phone))
            cursor.execute("COMMIT")
            return redirect('login_shop')
    # If the request is not a POST request, render the register template
    else:
        return render(request, 'registration/register.html')


# Update the product in the database
def edit_product(request, product_id):
    # Retrieve the product from the database
    global product_to_edit
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM products WHERE id_product = :id", {'id': product_id})
    product = cursor.fetchone()
    product_to_edit = product
    product_name = product_id

    if request.method == 'POST':
        form = EditProductForm(request.POST)
        if form.is_valid():
            # Requested choice for price, type
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


def edit_supply(request, supply_id):
    # Retrieve the product from the database
    cursor = connection.cursor()

    cursor.execute("SELECT * FROM supplies WHERE id_product = :id", {'id': supply_id})
    supply = cursor.fetchone()
    print("supply")

    #
    # if request.method == 'POST':
    #     form = EditProductForm(request.POST)
    #     if form.is_valid():
    #         # Requested choice for price, type
    #         price = form.cleaned_data['price']
    #         product_type = form.cleaned_data['product_type']
    #         product_type_label = "'" + dict(form.fields['product_type'].choices)[product_type] + "'"
    #
    #         # Requested choice for category
    #         category = form.cleaned_data['category']
    #         category_type_label = "'" + dict(form.fields['category'].choices)[category] + "'"
    #
    #         # Find the foreign key id_category for products table based on user choice
    #         cursor.execute("SELECT id_category from categories WHERE name = %s" % (category_type_label))
    #         category_fk = cursor.fetchone()[0]
    #
    #         # Requested choice for size
    #         size = form.cleaned_data['size']
    #         size_type_label = "'" + dict(form.fields['size'].choices)[size] + "'"
    #
    #         # Find the foreign key id_size for products table based on user choice
    #         cursor.execute("SELECT id_size from sizes WHERE name = %s" % (size_type_label))
    #         size_fk = cursor.fetchone()[0]
    #
    #         cursor.execute("UPDATE products\
    #                         SET price = %s, id_category = %s, id_size = %s, type = %s WHERE id_product = %s" \
    #                        % (price, category_fk, size_fk, product_type_label, product_id))
    #         cursor.execute("commit")
    #
    #         return redirect('home')
    # else:
    #     # Render the edit form
    #     form = EditProductForm(initial={'stock_quantity': product[1], 'price': product[2], 'product_type': product[5],
    #                                     'category': 1, 'size': 1}, )

    return render(request, 'edit_supply.html', {'form': form)


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
    return HttpResponse(template.render({'products': sorted(products), 'categories': categories}))


@csrf_exempt
def add_to_cart(request, product_id):
    if request.method == 'POST':
        # Get the quantity of the product
        quantity = int(request.POST['quantity'])

        # Check if the product is already in the order dictionary
        if product_id in order:
            # If yes, increase the quantity
            order[product_id] += quantity
        else:
            # If not, add the product to the order dictionary
            order[product_id] = quantity
    print(order)
    return redirect('home')


def remove_from_cart(request, product_id):
    if request.method == 'POST':
        # Remove the product from the cart
        order.pop(product_id, None)

    return redirect('view_cart')


def view_cart(request):
    # Get the cart data from the session
    # cursor = connection.cursor()
    # cursor.execute("SELECT role FROM accounts WHERE id_user = :id_client ", id_client=id_client)

    return render(request, 'cart.html', {'order': order, 'cart_length': len(order)})


def place_order(request):
    if request.method == 'POST':
        order_date = request.POST['order_date']
        order_date_obj = datetime.strptime(order_date, '%m/%d/%Y')
        order_date = order_date_obj.strftime('%Y-%m-%d')

        # Connect to the database
        cursor = connection.cursor()
        cursor.execute("SELECT username from accounts WHERE id_user = :id_client", id_client=id_client)
        username = cursor.fetchone()[0]

        # Insert the order into the "orders" table
        cursor.execute(
            "INSERT INTO orders(id_user, order_date) values (get_id_username(:username), to_date(:order_date, 'YYYY-MM-DD'))",
            {'username': username, 'order_date': order_date})

        # Insert the order details into the "orders_details" table
        for id_product, quantity in order.items():
            cursor.execute(
                "INSERT INTO orders_details(orders_id_order, products_id_product, order_quantity) values (orders_id_order_seq.currval, :id_product, :quantity)",
                {'id_product': id_product, 'quantity': quantity})

        # Commit the transaction
        cursor.execute("COMMIT")

        # Close the cursor
        cursor.close()
        order.clear()
    return redirect('home')


def add_product(request):
    if request.method == 'POST':
        form = ProductForm(request.POST)
        if form.is_valid():
            print(form.errors)
            # Save the product to the database
            price = form.cleaned_data['price']
            type = form.cleaned_data['type']
            category = "'" + form.cleaned_data['category'] + "'"
            size = "'" + form.cleaned_data['size'] + "'"

            print(price)
            print(type)
            print(category)
            print(size)

            # Connect to the database
            cursor = connection.cursor()

            # Find the foreign key id_category for products table based on user input
            cursor.execute("SELECT id_category from categories WHERE name = %s" % category)
            id_category = cursor.fetchone()[0]
            print(id_category)

            # Find the foreign key id_category for products table based on user input
            cursor.execute("SELECT id_size from sizes WHERE name = %s" % size)
            id_size = cursor.fetchone()[0]
            print(id_size)

            # Insert the product into the "products" table
            cursor.execute(
                "INSERT INTO products(price, type, id_category, id_size) values (:price, :type, :id_category, :id_size)",
                {'price': price, 'type': type, 'id_category': id_category, 'id_size': id_size})

            # Commit the transaction
            cursor.execute("COMMIT")

            # Close the cursor
            cursor.close()
            return redirect('home')
    else:
        form = ProductForm()
        return render(request, 'add_product.html', {'form': form})


def show_supplies(request):
    # Connect to the database
    cursor = connection.cursor()

    # Query the database to find all the supplies made
    cursor.execute("SELECT DISTINCT id_product FROM supplies")
    all_supplies = cursor.fetchall()
    category = request.GET.get('category')

    if category:
        cursor.execute(
            "SELECT s.id_product, p.stock_quantity, s.supply_quantity, s.supply_date from supplies s, products p WHERE p.id_product = s.id_product AND s.id_product = :category",
            {'category': category}
        )

    else:
        cursor.execute(
            "SELECT s.id_product, p.stock_quantity, s.supply_quantity, s.supply_date from supplies s, products p WHERE p.id_product = s.id_product")
    supplies = cursor.fetchall()

    return render(request, 'show_supplies.html', {'supplies': supplies, 'all_supplies': all_supplies})


def show_clients(request):
    # Connect to the database
    cursor = connection.cursor()

    # Query the database to find all the clients
    cursor.execute(
        "SELECT a.username, a.role, a.total_orders, u.first_name, u.last_name, u.address, u.email, u.phone FROM accounts a, user_details u WHERE a.id_user = u.id_user")
    clients = cursor.fetchall()

    return render(request, 'show_clients.html', {'clients': clients})


def show_orders(request):
    # Connect to the database
    cursor = connection.cursor()

    # Query the database to find all the clients
    cursor.execute(
        "SELECT o.id_order, o.order_date, a.username, o.payment, od.products_id_product, od.order_quantity FROM accounts a, orders o, orders_details od, products p WHERE a.id_user = o.id_user AND od.orders_id_order = o.id_order AND od.products_id_product = p.id_product")
    orders = sorted(cursor.fetchall())
    # Create a dictionary that groups the order details, products, and quantities by order ID
    orders_dict = {}
    for order in orders:
        order_id = order[0]
        order_date = order[1]
        username = order[2]
        payment = order[3]
        product_id = order[4]
        quantity = order[5]
        if order_id not in orders_dict:
            orders_dict[order_id] = {'order_date': order_date, 'username': username, 'payment': payment, 'products': {}}
        if product_id not in orders_dict[order_id]['products']:
            orders_dict[order_id]['products'][product_id] = quantity
        else:
            orders_dict[order_id]['products'][product_id] += quantity
    return render(request, 'show_orders.html', {'orders': orders_dict})


@csrf_exempt
def add_supply(request, product_id):
    product_name = product_id
    if request.method == 'POST':
        form = SuppliesForm(request.POST)
        if form.is_valid():
            cursor = connection.cursor()
            supply_date = form.cleaned_data['supply_date']
            supply_quantity = form.cleaned_data['supply_quantity']
            cursor.execute(
                "INSERT INTO supplies(id_product, supply_date, supply_quantity) VALUES(:id_product, :supply_date, :supply_quantity)",
                {'id_product': product_id, 'supply_date': supply_date, 'supply_quantity': supply_quantity})
            cursor.execute("COMMIT")
            return redirect('home')
    else:
        form = SuppliesForm(initial={'supply_date': datetime.date.today(), 'supply_quantity': 1})

    return render(request, 'add_supply.html', {'form': form, 'product_name': product_name})


@csrf_exempt
def delete_product(request, product_id):
    if request.method == 'POST':
        cursor = connection.cursor()
        cursor.execute("DELETE FROM supplies WHERE id_product = :product_id", {'product_id': product_id})
        cursor.execute("DELETE FROM orders_details WHERE products_id_product = :product_id", {'product_id': product_id})
        cursor.execute("DELETE FROM products WHERE id_product = :product_id", {'product_id': product_id})
        cursor.execute("COMMIT")
        return redirect('home')
