//
//  OverallStatsView.swift
//  CovidUI
//
//  Created by Mathias.Quintero on 4/20/20.
//  Copyright © 2020 Mathias.Quintero. All rights reserved.
//

import Foundation
import SwiftUI

struct StatsView: View {
    @GraphQL(Covid.Affected.cases)
    var cases: Int

    @GraphQL(Covid.Affected.deaths)
    var deaths: Int

    @GraphQL(Covid.Affected.recovered)
    var recovered: Int

    var body: some View {
        HStack {
            VStack {
                Text("Cases").font(.headline).fontWeight(.bold).foregroundColor(.primary)
                Text(cases.statFormatted).font(.callout).fontWeight(.medium).foregroundColor(.secondary)
            }

            Spacer()
            Divider().padding(.vertical, 8)
            Spacer()

            VStack {
                Text("Deaths").font(.headline).fontWeight(.bold).foregroundColor(.primary)
                Text(deaths.statFormatted).font(.callout).fontWeight(.medium).foregroundColor(.secondary)
            }

            Spacer()
            Divider().padding(.vertical, 8)
            Spacer()

            VStack {
                Text("Recovered").font(.headline).fontWeight(.bold).foregroundColor(.primary)
                Text(recovered.statFormatted).font(.callout).fontWeight(.medium).foregroundColor(.secondary)
            }
        }
    }

}

extension Int {
    var statFormatted: String {
        return Double(self).statFormatted
    }
}

extension Double {
    var statFormatted: String {

        if self >= 1000, self <= 999999 {
            return String(format: "%.1fK", locale: Locale.current,self/1000).replacingOccurrences(of: ".0", with: "")
        }

        if self > 999999 {
            return String(format: "%.1fM", locale: Locale.current,self/1000000).replacingOccurrences(of: ".0", with: "")
        }

        return String(format: "%.0f", locale: Locale.current,self)
    }
}
