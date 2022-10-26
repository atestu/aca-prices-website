module Jekyll
	class StatesGenerator < Generator
		safe true

		def generate(site)
			['MT','WY','UT','AZ','AK','TX','OK','KS','NE','SD','ND','WI','MO','LA','MS','AL','GA','TN','IN','OH','FL','SC','NC','VA','HI'].each do |state|
				site.pages << StatePage.new(site, site.source, state)
			end
		end
	end

  # A Page subclass used in the `fipsGenerator`
	class StatePage < Page
		def initialize(site, base, state)
			@site = site
			@base = base
			@dir  = File.join(state)
			@name = 'index.html'

			self.process(@name)
			self.read_yaml(File.join(base, '_layouts'), 'state.html')
	  		self.data['base_link'] = File.join(state)
			self.data['state'] = state
			self.data['counties'] = site.data['zip2fips'].values.select{ |fips| fips['state'] == state && site.data['fips_plans']['2021']['individual'].has_key?(fips['fips']) }.map{ |fips| fips['county'] }.uniq

			# category_title_prefix = site.config['category_title_prefix'] || 'Category: '
			# self.data['title'] = "#{category_title_prefix}#{category}"
		end
	end
end