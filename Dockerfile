FROM ruby:3.0.3

# Set the working directory in the container
WORKDIR /app

# Install Node.js for Rails asset compilation
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn

# Update Bundler to the version used in Gemfile.lock
RUN gem install bundler:2.3.16

# Copy the Gemfile and Gemfile.lock into the container
COPY Gemfile Gemfile.lock ./

# Bundle install to install the Ruby dependencies
RUN bundle install

# Additional dependencies for Nokogiri, if needed
# RUN apt-get install -y build-essential libxml2-dev libxslt-dev

# Copy the main application
COPY . .

# Expose the port the app runs on
EXPOSE 3000

# Start the application
CMD ["rails", "server", "-b", "0.0.0.0"]
