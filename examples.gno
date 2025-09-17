// ========================================
// 1. HELLO WORLD - Basic Gno Program
// ========================================

package hello

// Simple function that returns a greeting
func Hello() string {
    return "Hello, Gno World!"
}

// Function with parameters
func Greet(name string) string {
    return "Hello, " + name + "!"
}

// ========================================
// 2. SIMPLE COUNTER CONTRACT
// ========================================

package counter

var count int

// Initialize counter
func init() {
    count = 0
}

// Get current count
func GetCount() int {
    return count
}

// Increment counter
func Increment() {
    count++
}

// Decrement counter
func Decrement() {
    if count > 0 {
        count--
    }
}

// Reset counter to zero
func Reset() {
    count = 0
}

// Add specific amount to counter
func Add(amount int) {
    if amount > 0 {
        count += amount
    }
}

// ========================================
// 3. BASIC TOKEN CONTRACT
// ========================================

package token

import (
    "std"
    "strings"
)

var (
    name         string
    symbol       string
    totalSupply  uint64
    balances     map[string]uint64
    allowances   map[string]map[string]uint64
)

// Initialize token
func init() {
    name = "MyToken"
    symbol = "MTK"
    totalSupply = 1000000
    balances = make(map[string]uint64)
    allowances = make(map[string]map[string]uint64)
    
    // Give initial supply to contract deployer
    caller := std.GetOrigCaller()
    balances[caller.String()] = totalSupply
}

// Get token name
func Name() string {
    return name
}

// Get token symbol
func Symbol() string {
    return symbol
}

// Get total supply
func TotalSupply() uint64 {
    return totalSupply
}

// Get balance of an address
func BalanceOf(address string) uint64 {
    return balances[address]
}

// Transfer tokens
func Transfer(to string, amount uint64) bool {
    caller := std.GetOrigCaller().String()
    
    if balances[caller] < amount {
        panic("Insufficient balance")
    }
    
    balances[caller] -= amount
    balances[to] += amount
    
    return true
}

// ========================================
// 4. SIMPLE VOTING CONTRACT
// ========================================

package voting

import "std"

type Proposal struct {
    ID          int
    Title       string
    Description string
    YesVotes    int
    NoVotes     int
    IsActive    bool
}

var (
    proposals    []Proposal
    nextID       int
    voters       map[string]map[int]bool // voter -> proposal -> hasVoted
)

func init() {
    nextID = 1
    voters = make(map[string]map[int]bool)
}

// Create a new proposal
func CreateProposal(title, description string) int {
    proposal := Proposal{
        ID:          nextID,
        Title:       title,
        Description: description,
        YesVotes:    0,
        NoVotes:     0,
        IsActive:    true,
    }
    
    proposals = append(proposals, proposal)
    nextID++
    
    return proposal.ID
}

// Vote on a proposal
func Vote(proposalID int, voteYes bool) {
    caller := std.GetOrigCaller().String()
    
    // Initialize voter map if needed
    if voters[caller] == nil {
        voters[caller] = make(map[int]bool)
    }
    
    // Check if already voted
    if voters[caller][proposalID] {
        panic("Already voted on this proposal")
    }
    
    // Find and update proposal
    for i := range proposals {
        if proposals[i].ID == proposalID && proposals[i].IsActive {
            if voteYes {
                proposals[i].YesVotes++
            } else {
                proposals[i].NoVotes++
            }
            
            voters[caller][proposalID] = true
            return
        }
    }
    
    panic("Proposal not found or inactive")
}

// Get proposal details
func GetProposal(proposalID int) Proposal {
    for _, proposal := range proposals {
        if proposal.ID == proposalID {
            return proposal
        }
    }
    panic("Proposal not found")
}

// Close a proposal
func CloseProposal(proposalID int) {
    caller := std.GetOrigCaller().String()
    
    for i := range proposals {
        if proposals[i].ID == proposalID {
            proposals[i].IsActive = false
            return
        }
    }
    panic("Proposal not found")
}

// ========================================
// 5. SIMPLE MARKETPLACE CONTRACT
// ========================================

package marketplace

import "std"

type Item struct {
    ID          int
    Name        string
    Description string
    Price       uint64
    Seller      string
    IsAvailable bool
}

var (
    items    []Item
    nextItemID int
)

func init() {
    nextItemID = 1
}

// List an item for sale
func ListItem(name, description string, price uint64) int {
    caller := std.GetOrigCaller().String()
    
    item := Item{
        ID:          nextItemID,
        Name:        name,
        Description: description,
        Price:       price,
        Seller:      caller,
        IsAvailable: true,
    }
    
    items = append(items, item)
    nextItemID++
    
    return item.ID
}

// Get item details
func GetItem(itemID int) Item {
    for _, item := range items {
        if item.ID == itemID {
            return item
        }
    }
    panic("Item not found")
}

// Buy an item
func BuyItem(itemID int) {
    caller := std.GetOrigCaller().String()
    
    for i := range items {
        if items[i].ID == itemID && items[i].IsAvailable {
            if items[i].Seller == caller {
                panic("Cannot buy your own item")
            }
            
            // Mark as sold
            items[i].IsAvailable = false
            return
        }
    }
    panic("Item not found or not available")
}

// Get all available items
func GetAvailableItems() []Item {
    var available []Item
    for _, item := range items {
        if item.IsAvailable {
            available = append(available, item)
        }
    }
    return available
}

// ========================================
// 6. BASIC REGISTRY CONTRACT
// ========================================

package registry

import "std"

var records map[string]string

func init() {
    records = make(map[string]string)
}

// Register a key-value pair
func Register(key, value string) {
    caller := std.GetOrigCaller().String()
    
    if records[key] != "" {
        panic("Key already exists")
    }
    
    records[key] = value
}

// Update a record (only by original registrant)
func Update(key, newValue string) {
    caller := std.GetOrigCaller().String()
    
    if records[key] == "" {
        panic("Key does not exist")
    }
    
    records[key] = newValue
}

// Get a record
func Get(key string) string {
    return records[key]
}

// Check if key exists
func Exists(key string) bool {
    return records[key] != ""
}

// Delete a record
func Delete(key string) {
    caller := std.GetOrigCaller().String()
    
    if records[key] == "" {
        panic("Key does not exist")
    }
    
    delete(records, key)
}

// ========================================
// 7. BASIC UTILITIES AND HELPERS
// ========================================

package utils

import "std"

// Get current caller address
func GetCaller() string {
    return std.GetOrigCaller().String()
}

// Simple math functions
func Add(a, b int) int {
    return a + b
}

func Subtract(a, b int) int {
    return a - b
}

func Multiply(a, b int) int {
    return a * b
}

func Divide(a, b int) int {
    if b == 0 {
        panic("Division by zero")
    }
    return a / b
}

// String utilities
func IsEmpty(s string) bool {
    return s == ""
}

func Length(s string) int {
    return len(s)
}

// Array utilities
func Contains(slice []string, item string) bool {
    for _, s := range slice {
        if s == item {
            return true
        }
    }
    return false
}

// ========================================
// 8. TESTING FUNCTIONS
// ========================================

// These would typically be in separate test files
// but shown here for completeness

func TestCounter() {
    // Reset counter
    Reset()
    
    // Test increment
    Increment()
    if GetCount() != 1 {
        panic("Counter increment failed")
    }
    
    // Test add
    Add(5)
    if GetCount() != 6 {
        panic("Counter add failed")
    }
    
    // Test decrement
    Decrement()
    if GetCount() != 5 {
        panic("Counter decrement failed")
    }
}
