# lib/terminal_app.rb
require_relative 'client_loader'
require_relative 'client_searcher'

class TerminalApp
  PER_PAGE = 5
  attr_reader :clients, :keys, :searcher

  def initialize(file_path)
    @clients, @keys = ClientLoader.load(file_path)
    @searcher = ClientSearcher.new(@clients)
  end

  def run
    loop do
      print_menu
      case choice
      when '1' then handle_search
      when '2' then handle_duplicates
      when '3' then handle_list_all
      when '4' then break
      else
        puts 'Invalid choice. Try again.'
      end
    end
  end

  private

  def print_menu
    puts "\n== ShiftCare CLI =="
    puts '1. Search clients by field'
    puts '2. Find duplicate emails'
    puts '3. List all clients'
    puts '4. Exit'
    print '> '
  end

  def choice
    gets.strip
  end

  def handle_list_all
    puts "\n📋 All Clients:"
    @results = @clients
    paginate
  end

  def handle_search
    field = prompt_field_selection
    return unless field

    query = prompt_search_query(field)
    @results = @searcher.search_by_field(field, query)
    paginate
  end

  def handle_duplicates
    @results = @searcher.duplicate_emails
    paginate
  end

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

  def invalid_index?(index)
    index.negative? || index >= keys.size
  end

  def display_keys_with_index
    keys.each_with_index do |key, idx|
      puts "  #{idx + 1}. #{key}"
    end
  end

  def prompt_search_query(field)
    print "Enter search query for '#{field}': "
    gets.strip
  end

  def paginate
    if @results.empty?
      puts "\nNo results found."
      return
    end

    @page = 0
    @total_pages = nil
    pagination_loop
  end

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

  def total_pages
    @total_pages ||= (@results.length.to_f / PER_PAGE).ceil
  end

  def print_page(results, page, total_pages)
    puts "--- Page #{page + 1} of #{total_pages} ---"
    records = results.slice(page * PER_PAGE, PER_PAGE)
    puts '------------------------------------------'
    records.each { |r| puts r }
    puts '------------------------------------------'
    puts "\n(n)ext, (p)revious, (q)uit"
    print '> '
  end

  def pagination_input
    gets.strip.downcase
  end
end
