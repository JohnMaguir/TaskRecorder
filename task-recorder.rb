#!/usr/bin/ruby
require 'date'

def add_new_item(note, done_item=true)
  file_data = File.read("#{@root_dir}#{@todays_file}")
  lines = file_data.split("\n")
  position = -1
  position = lines.index("*Today*") if done_item
  lines.insert(position, ">#{note}")

  write_today(lines.join("\n"))
end

def write_today(content)
  File.write("#{@root_dir}#{@todays_file}", content)
end

def output_file_content(filename=nil)
  filename = @todays_file if filename.nil?
  puts File.read("#{@root_dir}#{filename}")
end

def notes_for_week
  today = Date.today
  friday = prior_friday(today)
  completed_tasks = []
  today.downto(friday) do |day|
    filename = "#{day.strftime('%F')}-tasks.md"
    next unless File.exist?("#{@root_dir}#{filename}")
    file_data = File.read("#{@root_dir}#{filename}")
    tasks = file_data.split("*Today*")[0].split("\n")
    # get rid of header
    tasks.shift
    completed_tasks.concat(tasks)
  end
  output = completed_tasks.flatten.uniq.join("\n")
  File.write("#{@root_dir}#{@weeks_file}", "*This Week*\n#{output}\n*Next Week*")
end

def edit_todays_notes
  system('vim', "#{@root_dir}#{@todays_file}")
end

def clean
  today = Date.today
  friday = prior_friday(today)
  save = today.downto(friday).map{|day| "#{day.strftime('%F')}-tasks.md"}
  save << @weeks_file
  Dir.foreach(@root_dir) do |filename|
    next if filename == '.' or filename == '..' or (save.include? filename)
    File.delete(filename)
  end
end

def prior_friday(date)
  days_before = (date.wday + 1) % 7 + 1
  date.to_date - days_before
end

# send row data to google sheet
def send_to_google_sheet

end

# send row data to google sheet
# use sheet id from google sheet url
# use API key from google cloud platform
def send_to_google_sheet
  require 'google/apis/sheets_v4'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'
  require 'fileutils'

  # Initialize the API
  service = Google::Apis::SheetsV4::SheetsService.new
  service.client_options.application_name = APPLICATION_NAME
  service.authorization = authorize

  # Prints the names and majors of students in a sample spreadsheet:
  # https://docs.google.com/spreadsheets/d/1pDp7xSg4mZ4f9Z9X4Z4K4Qz4Ww8wJv1Q0n3q3a3a3/edit
  spreadsheet_id = '1pDp7xSg4mZ4f9Z9X4Z4K4Qz4Ww8wJv1Q0n3q3a3a3'
  range = 'A1:C1'
  value_range_object = Google::Apis::SheetsV4::ValueRange.new
  value_range_object.range = range
  value_range_object.values = [["Name", "Major", "GPA"]]
  service.append_spreadsheet_value(spreadsheet_id, range, value_range_object, value_input_option: 'RAW')
end

commands = %i{done todo notes standup today edit clean help}
help_notes = {
  done: "Add task to done for today",
  todo: "Add task to todo for tomorrow",
  notes: "Compile notes of completed tasks for the week incl. prior Friday as weekly meeting is Friday morning",
  standup: "Output notes to be pasted in dev-standup this morning",
  today: "Output notes for today",
  edit: "Open todays notes in Vim for editing",
  clean: "Remove files from all weeks but this one and prior Friday",
  help: "Display help notes for commands"
}
requires_note = %i{done todo}
command = ARGV[0]&.to_sym
raise "Unsupporterd command #{command}" unless commands.include? command

note = ARGV[1]&.to_s
raise "Note required for #{command}" if note.nil? && (requires_note.include? command)

today = Date.today
@root_dir = "/home/onepagecrm/Documents/onepage_notes/onepage_notes/daily_standups/#{today.year}/" #"#{__dir__}/task_files/"
Dir.mkdir @root_dir unless File.exist?("#{@root_dir}")
@todays_file = "#{today.strftime('%F')}-tasks.md"
@weeks_file = "week-#{today.cweek}-#{today.year}-notes.md"
heading = today.friday? ? "*Friday*" : "*Yesterday*"
daily_template = "#{heading}\n*Today*\n"
write_today(daily_template) unless File.exist?("#{@root_dir}#{@todays_file}")

case command
when :done
  add_new_item(note)
  output_file_content
when :todo
  add_new_item(note, false)
  output_file_content
when :notes
  notes_for_week
  puts "Compiled notes for week "
  output_file_content(@weeks_file)
when :standup
  day = today.monday? ? prior_friday(today) : today.prev_day
  standup_file = "#{day.strftime('%F')}-tasks.md"
  output_file_content(standup_file)
when :today
  output_file_content
when :edit
  edit_todays_notes
when :clean
  clean
when :help
  puts "Possible commands:\n"
  help_notes.each do |command, info|
    puts "#{command} => #{info}\n"
  end
end
