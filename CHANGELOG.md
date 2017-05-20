# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### Added

### Changed

### Removed

### Fixed

## 0.1.3 - 2017-05-19

### Added
- ft_search_format and ft_search_count methods
- ft_search_format returns array of objects
- ft_add_hash and ft_del_all methods
- ft_sug* methods

### Changed
- ft_search returns raw FT.SEARCH results
- switched to keyword arguments
- passing offset and num to FT.SEARCH

## 0.1.2 - 2017-04-23

### Fixed
- variable scope with redi_search_schema

### Changed
- changed ft_search output to be an array of hashes
- changed dependencies to > Rails 4.2.8
