//
//  L10n.swift
//  Tracker
//
//  Created by Pavel Komarov on 13.08.2025.
//

import Foundation

enum L10n {
    enum Button {
        static let cancel = NSLocalizedString("cancelButton", comment: "Cancel button")
        static let create = NSLocalizedString("createButton", comment: "Create button")
        static let done = NSLocalizedString("doneButton", comment: "Done button")
        static let addCategory = NSLocalizedString("addCategoryButton", comment: "Add category button")
        static let onboarding = NSLocalizedString("onboardingButton", comment: "Onboarding finish button")
    }

    enum TrackerType {
        static let habit = NSLocalizedString("habitType", comment: "Habit tracker type")
        static let irregularEvent = NSLocalizedString("irregularEventType", comment: "Irregular event tracker type")
        static let newHabit = NSLocalizedString("newHabitTitle", comment: "New habit title")
        static let newIrregularEvent = NSLocalizedString("newIrregularEventTitle", comment: "New irregular event title")
    }

    enum Navigation {
        static let trackers = NSLocalizedString("trackersTab", comment: "Trackers tab title")
        static let statistics = NSLocalizedString("statisticsTab", comment: "Statistics tab title")
        static let schedule = NSLocalizedString("scheduleTitle", comment: "Schedule title")
        static let category = NSLocalizedString("categoryTitle", comment: "Category title")
        static let trackerCreation = NSLocalizedString("trackerCreationTitle", comment: "Tracker creation title")
        static let newCategory = NSLocalizedString("newCategoryTitle", comment: "New category title")
        static let emoji = NSLocalizedString("emojiSectionTitle", comment: "Emoji section title")
        static let color = NSLocalizedString("colorSectionTitle", comment: "Color section title")
    }

    enum Placeholder {
        static let trackerName = NSLocalizedString("trackerNamePlaceholder", comment: "Tracker name input placeholder")
        static let categoryName = NSLocalizedString("categoryNamePlaceholder", comment: "Category name input placeholder")
        static let search = NSLocalizedString("searchPlaceholder", comment: "Search bar placeholder")
    }

    enum DaysOfWeek {
        static let monday = NSLocalizedString("mondayFull", comment: "Monday")
        static let tuesday = NSLocalizedString("tuesdayFull", comment: "Tuesday")
        static let wednesday = NSLocalizedString("wednesdayFull", comment: "Wednesday")
        static let thursday = NSLocalizedString("thursdayFull", comment: "Thursday")
        static let friday = NSLocalizedString("fridayFull", comment: "Friday")
        static let saturday = NSLocalizedString("saturdayFull", comment: "Saturday")
        static let sunday = NSLocalizedString("sundayFull", comment: "Sunday")

        static let mondayShort = NSLocalizedString("mondayShort", comment: "Monday short")
        static let tuesdayShort = NSLocalizedString("tuesdayShort", comment: "Tuesday short")
        static let wednesdayShort = NSLocalizedString("wednesdayShort", comment: "Wednesday short")
        static let thursdayShort = NSLocalizedString("thursdayShort", comment: "Thursday short")
        static let fridayShort = NSLocalizedString("fridayShort", comment: "Friday short")
        static let saturdayShort = NSLocalizedString("saturdayShort", comment: "Saturday short")
        static let sundayShort = NSLocalizedString("sundayShort", comment: "Sunday short")
    }

    enum Message {
        static let emptyTrackers = NSLocalizedString("emptyTrackersMessage", comment: "Empty trackers state message")
        static let onboardingFirstPage = NSLocalizedString("onboardingFirstPage", comment: "First onboarding page text")
        static let onboardingSecondPage = NSLocalizedString("onboardingSecondPage", comment: "Second onboarding page text")
        static let categoriesDescription = NSLocalizedString("categoriesDescription", comment: "Categories empty state description")
        static let characterLimit = NSLocalizedString("characterLimitMessage", comment: "Character limit warning")
        static let everyDay = NSLocalizedString("everyDaySchedule", comment: "Every day schedule option")
        static let defaultCategory = NSLocalizedString("defaultCategoryName", comment: "Default category name")
    }
}
