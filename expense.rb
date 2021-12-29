#! /usr/bin/env ruby

require "pg"
require "io/console" # gives us access to IO#getch method, which waits for a single key to be pressed, and then returns that character right away.

class ExpenseData

  def initialize
    @dbconnection = PG.connect(dbname: "expenses") # Create db connection
    setup_schema # Create table if doesn't exist (see method implementation below)
  end
  
  def list_expenses
    result = dbconnection.exec("SELECT * FROM expenses ORDER BY created_on ASC;")
  
    display_result(result)
  end

  def add_expenses(amount, memo)
    dbconnection.exec_params("INSERT INTO expenses (amount, memo)
                       VALUES($1, $2);", [amount, memo])
  end

  def search_expenses(item)
    result = dbconnection.exec_params("SELECT * FROM expenses WHERE memo ILIKE $1;", ["%#{item}%"])

    display_result(result)
  end

  def delete_expense(id)
    deleted_expense = dbconnection.exec_params("SELECT * FROM expenses WHERE id = $1;", [id])
    
    if deleted_expense.values.empty?
      puts "There is no expense the id '#{id}'"
    else
      dbconnection.exec_params("DELETE FROM expenses WHERE id = $1;", [id])
    
      puts "The following expense has been deleted:"
      display_result(deleted_expense)
    end
  end

  def clear_all_expenses
    dbconnection.exec_params("DELETE FROM expenses;")
    puts "All expenses have been deleted."
  end

  def display_help
    puts <<~HELP
  
      An expense recording system
  
      Commands:
  
      add AMOUNT MEMO - record a new expense
      clear - delete all expenses
      list - list all expenses
      delete NUMBER - remove expense with id NUMBER
      search QUERY - list expenses with a matching memo field
  
    HELP
  end

  private

  attr_reader :dbconnection

  def display_result(result)
    count = result.ntuples
    if count == 0
      puts "There are no expenses" 
    else
      puts "There #{count > 1 ? 'are' : 'is'} #{count} expense#{"s" if count != 1}"
      result.each do |tuple|
        columns = [tuple["id"].rjust(3),
                  tuple["created_on"].rjust(10),
                  tuple["amount"].rjust(12),
                  tuple["memo"]]
    
        puts columns.join(" | ")
      end
      total = result.column_values(1).map(&:to_f).sum.round(2)
      puts "-" * 50
      puts "Total #{total.to_s.rjust(25)}"
    end
  end

  def setup_schema # the following exec statement will return count = 1 if the table exist or count = 0 otherwise
    result = dbconnection.exec("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'expenses';")
    if result[0]["count"] == '0'
      dbconnection.exec("CREATE TABLE expenses (
        id serial PRIMARY KEY,
        amount decimal(6,2) NOT NULL CHECK(amount >= 0.01),
        memo text NOT NULL,
        created_on date NOT NULL DEFAULT NOW()
      );")
    end
  end
end

class CLI
  def initialize
    @application = ExpenseData.new    # instance of the db connection as collaborator object
  end

  def run(command_arg)   # main logic in this run method
    first_arg = command_arg[0]
    case first_arg
    when 'list'
      @application.list_expenses
    when 'add'
      if command_arg[1] == nil || command_arg[2] == nil || command_arg.count > 3
        puts "You must provide an amount and a memo"
      else
        @application.add_expenses(command_arg[1], command_arg[2])
      end
    when 'search'
      @application.search_expenses(command_arg[1])
    when 'delete'
      @application.delete_expense(command_arg[1])
    when 'clear'
      puts "This will remove all expenses. Are you sure? (y/n)"
      answer = nil
      loop do
        answer = $stdin.getch     # $stdin is used to read input from the console.
        break if ['y', 'n'].include?(answer)
        puts "I didn't get that, are you sure you want to remove all expenses? (y/n)"
      end
      @application.clear_all_expenses if ['y', 'yes'].include?(answer)
    else
      @application.display_help
    end
  end

end

CLI.new.run(ARGV)   # ARGV returns the list of arguments passed on the command line in the form of a Ruby array
