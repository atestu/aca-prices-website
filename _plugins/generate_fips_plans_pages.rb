require 'date'

module Jekyll
	class FipsPlanGenerator < Generator
		safe true

		def generate(site)
			dir = site.config['fips_plans_dir'] || 'fips'
			(2021..Date.today.next_month(2).year).to_a.map(&:to_s).each do |year|
				# Skip years that don't have data
				next unless site.data['fips_plans'] && site.data['fips_plans'][year]

				['individual', 'couple', 'family'].each do |plan_type|
					# Skip if this plan type doesn't exist for this year
					next unless site.data['fips_plans'][year][plan_type]

					site.data['fips_plans'][year][plan_type].each_key do |fips|
						site.pages << FipsPlanPage.new(site, site.source, year, plan_type, fips)
					end
				end
			end
		end
	end

  # A Page subclass used in the `fipsPlanGenerator`
  class FipsPlanPage < Page
  	def initialize(site, base, year, plan_type, fips)
  		@site = site
  		@base = base
  		@dir  = File.join(site.data['fips2zips'][fips]['state'], Jekyll::Utils.slugify(site.data['fips2zips'][fips]['county']), plan_type)
  		@name = 'index.html'

  		fips_plans = site.data['fips_plans'][fips]
  		self.process(@name)
  		self.read_yaml(File.join(base, '_layouts'), 'fips_plans.html')
  		self.data['year'] = year
  		self.data['plan_type'] = plan_type
  		self.data['base_link'] = File.join(site.data['fips2zips'][fips]['state'], Jekyll::Utils.slugify(site.data['fips2zips'][fips]['county']))
  		self.data['fips'] = fips

  		# category_title_prefix = site.config['category_title_prefix'] || 'Category: '
  		# self.data['title'] = "#{category_title_prefix}#{category}"
  	end
  end
end
