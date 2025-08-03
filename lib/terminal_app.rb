# lib/terminal_app.rb
require_relative 'client_loader'
require_relative 'client_searcher'

##
# TerminalApp provides an interactive CLI for searching, listing, and finding duplicate clients.
#
# Features:
# - Search clients by any field
# - List all clients
# - Find duplicate emails
# - Paginated results
# - Refresh client data from file
#
# @example Run the app
#   TerminalApp.new('data/clients.json').run
class TerminalApp
  PER_PAGE = 5
  attr_reader :clients, :keys, :searcher

  def initialize(file_path)
    @file_path = file_path
    @clients = nil
    @keys = nil
    @searcher = nil
    load_data
  end

  ##
  # Loads client data and keys from the file, unless already cached.
  #
  # This method is called on initialization and when refreshing data.
  # It avoids reloading if data is already present.
  def load_data
    # caching data to avoid reloading unnecessarily
    return if @clients && @keys && @searcher

    @clients, @keys = ClientLoader.load(@file_path)
    @searcher = ClientSearcher.new(@clients)
  end

  ##
  # Refreshes client data by clearing cached values and reloading from file.
  #
  # Prints status messages before and after refresh.
  def refresh_data
    puts "\n Refreshing client data from file..."
    @clients = nil
    @keys = nil
    @searcher = nil
    load_data
    puts 'Done!'
  end

  ##
  # Runs the interactive CLI loop, displaying the menu and handling user choices.
  #
  # The loop continues until the user selects 'Exit'.
  def run
    loop do
      print_menu
      case choice
      when '1' then handle_search
      when '2' then handle_duplicates
      when '3' then handle_list_all
      when '4' then refresh_data
      when '5' then break
      else
        puts 'Invalid choice. Try again.'
      end
    end
  end

  private

  ##
  # Prints the main menu options to the terminal.
  def print_menu
    puts "\n== ShiftCare CLI =="
    puts '1. Search clients by field'
    puts '2. Find duplicate emails'
    puts '3. List all clients'
    puts '4. Refresh client data'
    puts '5. Exit'
    print '> '
  end

  ##
  # Reads and returns the user's menu choice from standard input.
  #
  # @return [String] The user's input.
  def choice
    gets.strip
  end

  ##
  # Handles the 'List all clients' menu option, paginating all clients.
  def handle_list_all
    puts "\n📋 All Clients:"
    @results = @clients
    paginate
  end

  ##
  # Handles the 'Search clients by field' menu option, paginating search results.
  def handle_search
    field = prompt_field_selection
    return unless field

    query = prompt_search_query(field)
    @results = @searcher.search_by_field(field, query)
    paginate
  end

  ##
  # Handles the 'Find duplicate emails' menu option, paginating duplicate results.
  def handle_duplicates
    puts "\n📋 Duplicate Emails:"
    @results = @searcher.duplicate_emails
    paginate
  end

  ##
  # Prompts the user to select a field for searching and returns the selected field.
  #
  # @return [String, nil] The selected field name, or nil if invalid.
  def prompt_field_selection
    puts "\nFields available for search:"
    display_keys_with_index
    print "\nSelect a field by number: "
    input = gets.strip
    index = input.to_i - 1
    if invalid_index?(index)
      puts "Invalid field selection. Please enter a number between 1 and #{keys.size}."
      return nil
    end
    keys[index]
  end

  ##
  # Checks if the given index is invalid for field selection.
  #
  # @param index [Integer] The index to check.
  # @return [Boolean] True if invalid, false otherwise.
  def invalid_index?(index)
    index.negative? || index >= keys.size
  end

  ##
  # Displays all available keys/fields with their index for selection.
  def display_keys_with_index
    keys.each_with_index do |key, idx|
      puts "  #{idx + 1}. #{key}"
    end
  end

  ##
  # Prompts the user to enter a search query for the selected field.
  #
  # @param field [String] The field to search.
  # @return [String] The user's search query.
  def prompt_search_query(field)
    print "Enter search query for '#{field}': "
    gets.strip
  end

  ##
  # Paginates the current results, displaying pages and handling navigation.
  def paginate
    if @results.empty?
      puts "\nNo results found."
      return
    end

    @page = 0
    @total_pages = nil
    pagination_loop
  end

  ##
  # Handles the pagination navigation loop, allowing user to move between pages.
  def pagination_loop
    loop do
      print_page(@results, @page, total_pages)
      case pagination_input
      when 'n'
        @page += 1 if @page + 1 < total_pages
      when 'p'
        @page -= 1 if @page > 0
      when 'q'
        break
      else
        puts 'Invalid input.'
      end
    end
  end

  ##
  # Calculates the total number of pages for the current results.
  #
  # This method divides the total number of results by the number of results per page (PER_PAGE),
  # and rounds up to ensure all results are included, even if the last page is not full.
  #
  # @return [Integer] Total number of pages for pagination.
  # @example
  #   # If there are 12 results and PER_PAGE is 5, total_pages will be 3
  #   @results = Array.new(12)
  #   total_pages #=> 3
  def total_pages
    # Calculate total pages by dividing result count by PER_PAGE and rounding up
    @total_pages ||= (@results.length.to_f / PER_PAGE).ceil
  end

  ##
  # Prints a single page of results to the terminal.
  #
  # @param results [Array<Client>] The array of client objects to paginate.
  # @param page [Integer] The current page index (0-based).
  # @param total_pages [Integer] The total number of pages.
  #
  # This method slices the results array to get only the records for the current page:
  #   records = results.slice(page * PER_PAGE, PER_PAGE)
  #
  # For example, if PER_PAGE is 5 and page is 2 (third page),
  #   records = results.slice(10, 5) # gets results[10] to results[14]
  #
  # It then prints each record in a formatted box, along with navigation options.
  def print_page(results, page, total_pages)
    puts "--- Page #{page + 1} of #{total_pages} ---"
    # Verbose: Slice results to get only the records for the current page
    # page * PER_PAGE is the starting index for the page
    # PER_PAGE is the number of records per page
    records = results.slice(page * PER_PAGE, PER_PAGE)
    puts '------------------------------------------'
    divider = "+#{'-' * 38}+"
    records.each do |r|
      puts "\n#{divider}\n| #{r.to_s.lines.map { |line| line.strip }.join("\n| ")}\n#{divider}"
    end
    puts '------------------------------------------'
    puts "\n(n)ext, (p)revious, (q)uit"
    print '> '
  end

  ##
  # Reads and returns the user's pagination navigation input.
  #
  # @return [String] The user's input, downcased.
  def pagination_input
    gets.strip.downcase
  end
end
