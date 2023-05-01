from shop import views
from shop.connect import connection


# Make the requested format for the dropdown checklist
def make_tuple(current_value, results):
    choices = [(str(1), current_value)]
    for index, item in enumerate(results):
        cnt = index
        if index == 0:
            cnt = index + 1
        if item[0] == current_value:
            cnt += 1
        if item[0] != current_value:
            choices.append((str(cnt + 1), item[0]))
    transformed_choices = []
    encountered = set()

    for choice in choices:
        if choice[0] not in encountered:
            encountered.add(choice[0])
            transformed_choices.append(choice)
        else:
            # If the item is a duplicate, generate a new number for it
            new_number = str(int(choice[0]) + 1)
            transformed_choices.append((new_number, choice[1]))
    return transformed_choices


# Query the database to extract the values for category dropdown checklist
def get_categories():
    cursor = connection.cursor()
    current_category_idx = views.product_to_edit[3]

    cursor.execute("SELECT name FROM categories WHERE id_category = :id", {'id': current_category_idx})
    current_category = cursor.fetchone()

    cursor.execute("SELECT name FROM categories")

    categories_results = cursor.fetchall()
    categories_choices = make_tuple(current_category[0], categories_results)

    return categories_choices


# Query the database to extract the values for sizes dropdown checklist
def get_sizes():
    cursor = connection.cursor()

    current_size_idx = views.product_to_edit[4]
    cursor.execute("SELECT name FROM sizes WHERE id_size = :id", {'id': current_size_idx})
    current_size = cursor.fetchone()

    cursor.execute("SELECT name FROM sizes")
    sizes_results = cursor.fetchall()
    sizes_choices = make_tuple(current_size[0], sizes_results)

    return sizes_choices


# Query the database to extract the values for types dropdown checklist
def get_types():
    current_type = views.product_to_edit[5]

    cursor = connection.cursor()
    cursor.execute("SELECT DISTINCT  type FROM products")
    types_results = cursor.fetchall()
    types_choices = [(str(1), current_type)]

    for index, item in enumerate(types_results):
        if item[0] != current_type:
            types_choices.append((str(index + 1), item[0]))
    print(types_choices)
    return types_choices
