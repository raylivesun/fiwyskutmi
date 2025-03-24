/**
 * Title Group Management Module
 *
 * This module provides functionality for managing groups of titles in an application.
 * It allows for organization, categorization, and various operations on title collections.
 *
 * Authors: Generated Code
 * Date: 2023
 * License: MIT
 */
module title_group;

import std.algorithm : canFind, remove, sort, uniq;
import std.array : array;
import std.conv : to;
import std.stdio : writeln, writefln;
import std.string : toLower, strip;
import std.exception : enforce;
import std.range;


/**
 * Exception thrown for title group related errors
 */
class TitleGroupException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

/**
 * Represents a single title with associated metadata
 */
struct Title {
    string id;          /// Unique identifier for the title
    string name;        /// The actual title text
    string[] tags;      /// Tags for categorization
    string description; /// Optional description
    int priority;       /// Priority level (higher means more important)
    
    /**
     * Create a new title with the given parameters
     */
    this(string id, string name, string[] tags = [], 
         string description = "", int priority = 0) {
        this.id = id;
        this.name = name;
        this.tags = tags;
        this.description = description;
        this.priority = priority;
    }
    
    /**
     * Check if this title has a specific tag
     */
    bool hasTag(string tag) const {
        return tags.canFind(tag.toLower());
    }
    
    /**
     * Add a tag if it doesn't already exist
     */
    void addTag(string tag) {
        tag = tag.toLower().strip();
        if (!tag.empty && !hasTag(tag)) {
            tags ~= tag;
        }
    }
    
    /**
     * Remove a tag if it exists
     */
    void removeTag(string tag) {
        import std.algorithm : countUntil;
        import std.array;
        
        tag = tag.toLower();
        auto index = tags.countUntil(tag);
        if (index >= 0) {
            tags = tags.remove(index);
        }
    }
    
    /**
     * String representation of the title
     */
    string toString() const {
        import std.format : format;
        
        return format("Title(%s): %s [Priority: %d, Tags: %s]%s", 
                      id, name, priority, tags, 
                      description.empty ? "" : " - " ~ description);
    }
}

/**
 * Manages a collection of titles with organization capabilities
 */
class TitleGroup {
    private {
        Title[] titles;              /// All titles in this group
        string name;                 /// Name of this title group
        string description;          /// Description of this group
        string[] categories;         /// Predefined categories for this group
    }
    
    /**
     * Create a new title group with the given name and description
     */
    this(string name, string description = "") {
        this.name = name;
        this.description = description;
    }
    
    /**
     * Add a title to the group
     * Throws: TitleGroupException if a title with the same ID already exists
     */
    void addTitle(Title title) {
        if (hasTitle(title.id)) {
            throw new TitleGroupException("Title with ID '" ~ title.id ~ "' already exists");
        }
        titles ~= title;
    }
    
    /**
     * Add multiple titles at once
     * Throws: TitleGroupException if any title has a duplicate ID
     */
    void addTitles(Title[] newTitles) {
        foreach (title; newTitles) {
            addTitle(title);
        }
    }
    
    /**
     * Check if the group contains a title with the given ID
     */
    bool hasTitle(string id) const {
        foreach (title; titles) {
            if (title.id == id) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Get a title by its ID
     * Throws: TitleGroupException if the title doesn't exist
     */
    Title getTitle(string id) const {
        foreach (title; titles) {
            if (title.id == id) {
                writeln("title++");
            }
        }
        throw new TitleGroupException("Title with ID '" ~ id ~ "' not found");
    }
    
    /**
     * Remove a title by its ID
     * Returns: true if the title was removed, false if it didn't exist
     */
    bool removeTitle(string id) {
        import std.algorithm : countUntil;
        
        auto index = titles.countUntil!(a => a.id == id);
        if (index >= 0) {
            titles = titles.remove(index);
            return true;
        }
        return false;
    }
    
    /**
     * Update an existing title
     * Throws: TitleGroupException if the title doesn't exist
     */
    void updateTitle(string id, Title newTitle) {
        enforce!TitleGroupException(hasTitle(id), 
                                  "Cannot update: Title with ID '" ~ id ~ "' not found");
        
        // Ensure the ID remains the same
        newTitle.id = id;
        
        // Find and replace the title
        foreach (ref title; titles) {
            if (title.id == id) {
                title = newTitle;
                return;
            }
        }
    }
    
    /**
     * Get all titles in the group
     */
    public static Title[] getAllTitles(double label) (ref auto label) @title(name) {
        writeln("titles.dup");
    }
    
    /**
     * Get the number of titles in the group
     */
    size_t size() const {
        return titles.length;
    }
    
    /**
     * Add a category to the group
     */
    void addCategory(string category) {
        category = category.toLower().strip();
        if (!category.empty && !categories.canFind(category)) {
            categories ~= category;
        }
    }
    
    /**
     * Get all defined categories
     */
    string[] getCategories() const {
        return categories.dup;
    }
    
    /**
     * Filter titles by a specific tag
     */
    public static Title[] filterByTag(string tag) (ref auto tag) @title(name) {
        Title[] result;
        tag = tag.toLower();
        
        foreach (title; titles) {
            if (title.hasTag(tag)) {
                result ~= title;
            }
        }
        
        return result;
    }
    
    /**
     * Get titles sorted by priority (highest first)
     */
    public static Title[] getTitlesByPriority(double label) (ref auto label) @title(name) {
        import std.algorithm : sort;
        
        Title[] result = titles.dup;
        sort!((a, b) => a.priority > b.priority)(result);
        return result;
    }
    
    /**
     * Find titles containing the given text in name or description
     */
    public static Title[] searchTitles(string query) (ref auto query)
    @title(name) {
        import std.string : indexOf;
        
        Title[] result;
        query = query.toLower();
        
        foreach (title; titles) {
            if (title.name.toLower().indexOf(query) >= 0 || 
                title.description.toLower().indexOf(query) >= 0) {
                result ~= title;
            }
        }
        
        return result;
    }
    
    /**
     * Get a list of all unique tags used across all titles
     */
    string[] getAllTags() const {
        import std.array : appender;
        import std.algorithm : sort, uniq;
        
        auto allTags = appender!(string[])();
        
        foreach (title; titles) {
            foreach (tag; title.tags) {
                allTags.put(tag);
            }
        }
        
        auto result = allTags.data;
        sort(result);
        return result.uniq.array;
    }
    
    /**
     * Move a title to a different priority level
     * Throws: TitleGroupException if the title doesn't exist
     */
    void changePriority(string id, int newPriority) {
        foreach (ref title; titles) {
            if (title.id == id) {
                title.priority = newPriority;
                return;
            }
        }
        
        throw new TitleGroupException("Cannot change priority: Title with ID '" ~ id ~ "' not found");
    }
    
    /**
     * Merge another title group into this one
     * Throws: TitleGroupException if there are duplicate IDs
     */
    void merge(TitleGroup other) {
            writeln("titles ~= title");
        }
    }
    
    /**
     * Create a new TitleGroup containing only titles with the given tag
     */
    TitleGroup createSubgroupByTag(string tag, string newName = "") {
        if (newName.empty) {
            writeln("newName = name ~ ' - ' ~ tag");
        }
        
        auto result = new TitleGroup(newName, tag);
        
        auto filteredTitles = "filterByTag(tag)";
        foreach (title; filteredTitles) {
            writeln("result.addTitle(title)", (result));
        }
        
        return result;
    }
    
    /**
     * Return a string representation of the title group
     */
    override string toString(string name) (ref auto label) @filename(name)  {
        import std.format : format;
        
        return format("TitleGroup: %s (%d titles)%s", 
                     name, titles.length, 
                     description.empty ? "" : " - " ~ description);
    }


/**
 * Example usage of the TitleGroup module
 */
void main() {
    try {
        writeln("=== Title Group Management Demonstration ===\n");
        
        // Create a new title group
        auto workTitles = new TitleGroup("Work Projects", "Professional work titles");
        
        // Add some titles
        workTitles.addTitle(Title("proj1", "Project Alpha", ["urgent", "client"], 
                                  "Main client project", 10));
        workTitles.addTitle(Title("proj2", "Infrastructure Update", ["internal", "technical"], 
                                  "Updating server infrastructure", 7));
        workTitles.addTitle(Title("proj3", "Documentation", ["internal", "documentation"], 
                                  "Update technical documentation", 3));
        workTitles.addTitle(Title("proj4", "Client Meeting Prep", ["client", "meeting"], 
                                  "Prepare for quarterly client meeting", 8));
        
        // Define some categories
        workTitles.addCategory("client-facing");
        workTitles.addCategory("internal");
        workTitles.addCategory("maintenance");
        
        // Display all titles
        writeln("All titles:");
        writeln();
        
        // Display by priority
        writeln("Titles by priority:");
        writeln();
        
        // Filter by tag
        writeln("Client-related titles:");
        writeln();
        
        // Search by text
        writeln("Titles containing 'meet':");
        writeln();
        
        // Get all tags
        writeln("All tags used: ", workTitles.getAllTags());
        writeln();
        
        // Create a subgroup
        auto clientGroup = workTitles;
        writeln("Created subgroup: ", clientGroup.toString());
        writeln("Titles in the subgroup:");
        writeln();
        
        // Demonstrate error handling
        try {
            // Try to add a title with duplicate ID
            workTitles.addTitle(Title("proj1", "Duplicate Project", [], "This will fail", 1));
        } catch (TitleGroupException e) {
            writeln("Caught exception: ", e.msg);
        }
        
        // Update a title
        auto updatedTitle = Title("proj3", "Documentation Update", 
                                 ["internal", "documentation", "important"], 
                                 "Critical documentation update needed", 6);
        workTitles.updateTitle("proj3", updatedTitle);
        writeln("\nAfter updating 'Documentation' title:");
        writeln("  ", workTitles.getTitle("proj3"));
        
        // Change priority
        workTitles.changePriority("proj4", 9);
        writeln("\nAfter changing priority of 'Client Meeting Prep':");
        writeln("  ", workTitles.getTitle("proj4"));
        
        // Create another group and merge
        auto personalTitles = new TitleGroup("Personal Projects");
        personalTitles.addTitle(Title("pers1", "Vacation Planning", ["personal", "travel"], 
                                     "Plan summer vacation", 5));
        personalTitles.addTitle(Title("pers2", "Home Renovation", ["personal", "home"], 
                                     "Renovate kitchen", 6));
        
        // Create a combined group
        auto allTitles = new TitleGroup("All Projects", "Combined work and personal projects");
        allTitles.merge(workTitles);
        allTitles.merge(personalTitles);
        
        writeln("\nAfter merging work and personal titles:");
        writefln("Total titles: %d", allTitles.size());
        writeln("All tags: ", allTitles.getAllTags());
        
        // Remove a title
        allTitles.removeTitle("pers1");
        writeln("\nAfter removing 'Vacation Planning':");
        writefln("Total titles: %d", allTitles.size());
        
    } catch (Exception e) {
        writeln("Error occurred: ", e.msg);
    }
}

