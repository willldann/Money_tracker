import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mt1/models/database.dart';
import 'package:mt1/models/transaction_with_category.dart';

class TransactionPage extends StatefulWidget {
  final TransactionWithCategory? transactionsWithCategory;
  const TransactionPage({Key? key, required this.transactionsWithCategory})
      : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late int type;
  final AppDb database = AppDb();
  Category? selectedCategory;
  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Future<void> insertTransaction(
    String description,
    int categoryId,
    int amount,
    DateTime transactionDate,
  ) async {
    DateTime now = DateTime.now();
    try {
      await database.into(database.transactions).insert(
        TransactionsCompanion.insert(
          description: description,
          category_id: categoryId,
          amount: amount,
          transaction_date: transactionDate,
          created_at: now,
          updated_at: now,
        ),
      );
    } catch (e) {
      print("Error inserting transaction: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.transactionsWithCategory != null) {
      descriptionController.text =
          widget.transactionsWithCategory!.transaction.description;
      amountController.text =
          widget.transactionsWithCategory!.transaction.amount.toString();
      dateController.text = DateFormat('yyyy-MM-dd').format(
          widget.transactionsWithCategory!.transaction.transaction_date);
      selectedCategory = widget.transactionsWithCategory!.category;
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transactionsWithCategory != null
              ? 'Edit Transaction'
              : 'Add Transaction',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<Category>>(
        future: database.select(database.categories).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading categories'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories found'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: const OutlineInputBorder(),
                      labelStyle: GoogleFonts.poppins(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<Category>(
                    isExpanded: true,
                    value: selectedCategory,
                    hint: Text(
                      'Select Category',
                      style: GoogleFonts.poppins(),
                    ),
                    items: snapshot.data!.map((Category value) {
                      return DropdownMenuItem<Category>(
                        value: value,
                        child: Text(value.name, style: GoogleFonts.poppins()),
                      );
                    }).toList(),
                    onChanged: (Category? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: const OutlineInputBorder(),
                      labelStyle: GoogleFonts.poppins(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: const OutlineInputBorder(),
                      labelStyle: GoogleFonts.poppins(),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          dateController.text =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                        });
                      }
                    },
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (descriptionController.text.isEmpty ||
                          amountController.text.isEmpty ||
                          dateController.text.isEmpty ||
                          selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please complete all fields'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        int amount = int.tryParse(amountController.text) ?? 0;
                        if (amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Amount must be greater than 0'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          insertTransaction(
                            descriptionController.text,
                            selectedCategory!.id,
                            amount,
                            DateTime.parse(dateController.text),
                          );
                          Navigator.pop(context, true);
                        }
                      }
                    },
                    child: Text(
                      widget.transactionsWithCategory != null
                          ? 'Update'
                          : 'Save',
                      style: GoogleFonts.poppins(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
