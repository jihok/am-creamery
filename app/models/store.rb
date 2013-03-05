class Store < ActiveRecord::Base
  # Callbacks
  before_save :reformat_phone
  
  # Relationships
  has_many :assignments
  has_many :employees, :through => :assignments
  has_many :shifts, :through => :assignments
  
  
  # Validations
  # make sure required fields are present
  validates_presence_of :name, :street, :city
  # if state is given, must be one of the choices given (no hacking this field)
  validates_inclusion_of :state, :in => %w[PA OH WV], :message => "is not an option"
  # if zip included, it must be 5 digits only
  validates_format_of :zip, :with => /^\d{5}$/, :message => "should be five digits long"
  # phone can have dashes, spaces, dots and parens, but must be 10 digits
  validates_format_of :phone, :with => /^\(?\d{3}\)?[-. ]?\d{3}[-.]?\d{4}$/, :message => "should be 10 digits (area code needed) and delimited with dashes only"
  # make sure stores have unique names
  validates_uniqueness_of :name
  
  # Scopes
  scope :alphabetical, order('name')
  scope :active, where('active = ?', true)
  scope :inactive, where('active = ?', false)
  
  
  # Misc Constants
  STATES_LIST = [['Ohio', 'OH'],['Pennsylvania', 'PA'],['West Virginia', 'WV']]
  
  def recent_hours
    hours = 0
    shifts.completed.for_past_days(14).each do |x|
      if x.start_time < x.end_time
        hours += (x.end_time.to_s(:number).to_i - x.start_time.to_s(:number).to_i)/(60*60)
      else
        hours += (24*60*60 - x.start_time.to_s(:number).to_i)/(60*60)
        hours += (x.end_time.to_s(:number).to_i + 24*60*60)/(60*60)
      end
    end
    return hours
  end

  def create_map_link(zoom=13,width=800,height=800)
    markers = ""; i=1
    stores.all.each do |attr|
      markers += "&markers=color:red%7Ccolor:red%7Clabel:#{i}%7C#{attr.lat},#{attr.lon}"
      i += 1
    end
    map = "http://maps.google.com/maps/api/staticmap?center=#{lat},#{lon}&zoom=13&size=#{width}x#{height}&maptype=roadmap#{markers}&sensor=false"
  end

  def single_store_map(zoom=16,width=400,height=400)
    markers = ""; i=""
    lat = self.get_lat
    lon = self.get_lon
    markers += "&markers=color:red%7Ccolor:red%7Clabel:#{i}%7C#{lat},#{lon}"
    map = "http://maps.google.com/maps/api/staticmap?center=#{lat},#{lon}&zoom=#{zoom}&size=#{width}x#{height}&maptype=roadmap#{markers}&sensor=false"
  end

  def get_lat
    return find_store_lat
  end


  def get_lon
    return find_store_lon
  end

  # Callback code
  # -----------------------------
  private
  # We need to strip non-digits before saving to db
  def reformat_phone
    phone = self.phone.to_s  # change to string in case input as all numbers 
    phone.gsub!(/[^0-9]/,"") # strip all non-digits
    self.phone = phone       # reset self.phone to new string
  end

  def find_store_lat
    coord = Geokit::Geocoders::GoogleGeocoder.geocode("#{street}, #{city}, #{state}")
    if coord.success
      return coord.lat
    else
      errors.add_to_base("Error with geocoding")
    end
  end

  def find_store_lon
    coord = Geokit::Geocoders::GoogleGeocoder.geocode("#{street}, #{city}, #{state}")
    if coord.success
      return coord.lng
    else
      errors.add_to_base("Error with geocoding")
    end
  end

end
